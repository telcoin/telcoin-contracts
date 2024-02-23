// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {AccessControlUpgradeable, SafeERC20, Stablecoin, StablecoinHandler} from "../../stablecoin/StablecoinHandler.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ISimplePlugin} from "../interfaces/ISimplePlugin.sol";

// TESTING ONLY
contract MockAmirX is StablecoinHandler {
    using SafeERC20 for Stablecoin;
    using SafeERC20 for ERC20;

    struct DefiSwap {
        // Address of the swap aggregator or router
        address aggregator;
        // Plugin for handling referral fees
        ISimplePlugin plugin;
        // Token collected as fees
        ERC20 feeToken;
        // Address to receive referral fees
        address referrer;
        // Amount of referral fee
        uint256 referralFee;
        // Data for wallet interaction, if any
        bytes walletData;
        // Data for performing the swap, if any
        bytes swapData;
    }

    // Telcoin token address on Polygon network
    ERC20 public TELCOIN;
    // MATIC address on Polygon network
    address public constant MATIC = 0x0000000000000000000000000000000000001010;
    // Authorized Role
    bytes32 public constant SUPPORT_ROLE = keccak256("SUPPORT_ROLE");

    // TESTING ONLY
    constructor(ERC20 telcoin) {
        TELCOIN = telcoin;
    }

    /************************************************
     *   initializer
     ************************************************/

    function initialize() public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        __StablecoinHandler_init();
    }

    /************************************************
     *   swap functions
     ************************************************/

    /**
     * @notice Handles stablecoin swaps and triggers DeFi swap operations.
     * @dev Validates stablecoin swap parameters, performs swaps, and handles DeFi interactions based on provided DefiSwap details.
     * @param wallet Address initiating the swap.
     * @param safe Safe address for temporary token storage if needed.
     * @param ss StablecoinSwap structure with swap details.
     * @param defi DefiSwap structure with DeFi swap details.
     */
    function stablecoinSwap(
        address wallet,
        address safe,
        StablecoinSwap memory ss,
        DefiSwap memory defi
    ) external payable onlyRole(SWAPPER_ROLE) {
        // checks if it will fail
        _verifyStablecoin(wallet, safe, ss, defi);

        //eXYZ ot eXYZ
        if (isXYZ(ss.origin) && isXYZ(ss.target)) {
            swapAndSend(wallet, ss);
            return;
        }

        //stablecoin swap
        if (isXYZ(ss.origin) && !isXYZ(ss.target))
            convertFromEXYZ(wallet, safe, ss);

        //defi swap
        uint256 iBalance = ERC20(ss.origin).balanceOf(wallet);
        if (defi.walletData.length != 0) defiSwap(wallet, safe, defi);
        uint256 fBalance = ERC20(ss.origin).balanceOf(wallet);
        // //stablecoin swap
        if (!isXYZ(ss.origin) && isXYZ(ss.target)) {
            if (fBalance - iBalance != 0) ss.oAmount = fBalance - iBalance;
            convertToEXYZ(wallet, safe, ss);
        }
    }

    /**
     * @notice Performs a DeFi swap using the provided DefiSwap details.
     * @dev Executes wallet transaction and fee dispersal as part of the swap process.
     * @param wallet Address initiating the swap.
     * @param safe Safe address for temporary token storage if needed.
     * @param defi DefiSwap structure with DeFi swap details.
     */
    function defiSwap(
        address wallet,
        address safe,
        DefiSwap memory defi
    ) public payable onlyRole(SWAPPER_ROLE) {
        (bool walletResult, ) = wallet.call{value: 0}(defi.walletData);
        require(walletResult, "AmirX: wallet transaction failed");

        _feeDispersal(safe, defi);
    }

    /************************************************
     *   internal functions
     ************************************************/

    /**
     * @notice Handles the dispersal of fees collected during a DeFi swap.
     * @dev Executes the buyback of fee tokens and handles referral fees if applicable.
     * @param safe Safe address for receiving the remaining buyback tokens.
     * @param defi DefiSwap structure with DeFi swap details.
     */
    function _feeDispersal(address safe, DefiSwap memory defi) internal {
        // must buy into TEL
        if (defi.feeToken != TELCOIN)
            _buyBack(defi.feeToken, defi.aggregator, defi.swapData);

        // distribute reward
        if (defi.referrer != address(0) && defi.referralFee != 0) {
            TELCOIN.safeTransferFrom(safe, address(this), defi.referralFee);
            TELCOIN.forceApprove(address(defi.plugin), 0);
            TELCOIN.safeIncreaseAllowance(
                address(defi.plugin),
                defi.referralFee
            );
            require(
                defi.plugin.increaseClaimableBy(
                    defi.referrer,
                    defi.referralFee
                ),
                "AmirX: balance was not adjusted"
            );
        }
        // retain remainder
        if (TELCOIN.balanceOf(address(this)) > 0)
            TELCOIN.safeTransfer(safe, TELCOIN.balanceOf(address(this)));
    }

    /**
     * @notice Performs a token buyback using the collected fees.
     * @dev Supports buyback for ERC20 tokens and MATIC, handling the swap via the specified aggregator.
     * @param feeToken The token to be bought back.
     * @param aggregator The swap aggregator address.
     * @param swapData Data required to perform the swap.
     */
    function _buyBack(
        ERC20 feeToken,
        address aggregator,
        bytes memory swapData
    ) internal {
        if (address(feeToken) == address(0)) return;
        if (address(feeToken) == MATIC) {
            (bool maticSwap, ) = aggregator.call{value: msg.value}(swapData);
            require(maticSwap, "AmirX: MATIC swap transaction failed");
        } else {
            // zero out approval
            feeToken.forceApprove(aggregator, 0);
            feeToken.safeIncreaseAllowance(
                aggregator,
                feeToken.balanceOf(address(this))
            );

            (bool ercSwap, ) = aggregator.call{value: 0}(swapData);
            require(ercSwap, "AmirX: token swap transaction failed");
        }
    }

    /************************************************
     *   view functions
     ************************************************/

    /**
     * @notice Validates the stablecoin swap and DefiSwap parameters before execution.
     * @dev Checks for valid wallet and safe addresses, and additional validations based on DefiSwap details.
     * @param wallet Address initiating the swap.
     * @param safe Safe address for temporary token storage if needed.
     * @param ss StablecoinSwap structure with swap details.
     * @param defi DefiSwap structure with DeFi swap details.
     */
    function _verifyStablecoin(
        address wallet,
        address safe,
        StablecoinSwap memory ss,
        DefiSwap memory defi
    ) internal view {
        if (wallet == address(0)) revert ZeroValueInput("WALLET");

        //if either origin or target are not xyz the safe cannot be zero
        if (!isXYZ(ss.origin) || !isXYZ(ss.target))
            if (safe == address(0)) revert ZeroValueInput("SAFE");
        // calls if defi swap was submitted
        if (defi.walletData.length != 0) _verifyDefi(wallet, safe, defi);
    }

    /**
     * @notice Performs additional validations for the DefiSwap parameters.
     * @dev Ensures feeToken, aggregator, and swapData are valid for buyback operations.
     * @param defi DefiSwap structure with DeFi swap details.
     */
    function _verifyDefi(address, address, DefiSwap memory defi) internal view {
        // validate pathway
        if (defi.feeToken != TELCOIN && address(defi.feeToken) != address(0)) {
            if (defi.aggregator == address(0) || defi.swapData.length == 0)
                revert ZeroValueInput("BUYBACK");
        }
        // determines if there is a referrer increase
        if (defi.referrer != address(0)) {
            if (address(defi.plugin) == address(0))
                revert ZeroValueInput("PLUGIN");
        }
    }

    /************************************************
     *   support functions
     ************************************************/

    /**
     * @notice Rescues crypto assets mistakenly sent to the contract.
     * @dev Allows for the recovery of both ERC20 tokens and native MATIC sent to the contract.
     * @param token The token to rescue.
     * @param amount The amount of the token to rescue.
     */
    function rescueCrypto(
        ERC20 token,
        uint256 amount
    ) public onlyRole(SUPPORT_ROLE) {
        if (address(token) != MATIC) {
            // ERC20s
            token.safeTransfer(_msgSender(), amount);
        } else {
            // MATIC
            (bool sent, ) = _msgSender().call{value: amount}("");
            require(sent, "AmirX: MATIC send failed");
        }
    }

    //FOR TESTING ONLY
    receive() external payable {}
}
