// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Withdrawable} from "./interfaces/IERC20Withdrawable.sol";
import {IPOSBridge} from "./interfaces/IPOSBridge.sol";

/**
 * @title RootBridgeRelay
 * @author Amir Shirif
 * @notice A Telcoin Contract
 * @notice This contract is meant for forwarding ERC20 and ETH accross the polygon bridge system
 */
contract BridgeRelay {
    using SafeERC20 for IERC20;
    // emitted attemped MATIC bridging
    error MATICUnbridgeable();

    //ETHER address
    IERC20 public constant ETHER =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    // WETH address
    IERC20 public constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    //MATIC address
    IERC20 public constant MATIC =
        IERC20(0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0);
    // mainnet PoS bridge
    IPOSBridge public constant POS_BRIDGE =
        IPOSBridge(0xA0c68C638235ee32657e8f720a23ceC1bFc77C77);
    // mainnet predicate
    address public constant PREDICATE_ADDRESS =
        0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;
    // Owner address
    address public constant OWNER_ADDRESS =
        0xE075504E14bBB4d2aA6333DB5b8EFc1e8c2AE05B;

    /**
     * @dev Bridges specified ERC20 token across the Polygon bridge. Reverts for MATIC. Unwraps WETH to ETH for bridging as ETH.
     * @param token The ERC20 token to bridge.
     */
    function bridgeTransfer(IERC20 token) external {
        if (token == MATIC) revert MATICUnbridgeable(); // Revert if trying to bridge MATIC

        if (token == WETH) {
            // If token is WETH, convert it to ETH by withdrawing
            IERC20Withdrawable(address(WETH)).withdraw(
                WETH.balanceOf(address(this))
            );
        }

        if (token == ETHER || token == WETH)
            depositEther(); // Bridge as ETH
        else depositERC(token); // Bridge as ERC20 token
    }

    /**
     * @dev Internal function to handle bridging of ERC20 tokens.
     * @param token The ERC20 token to bridge.
     * @return success Boolean value indicating if the operation was successful.
     */
    function depositERC(IERC20 token) internal returns (bool) {
        // Reset allowance and set it to the token balance of this contract
        token.forceApprove(PREDICATE_ADDRESS, 0);
        token.safeIncreaseAllowance(
            PREDICATE_ADDRESS,
            token.balanceOf(address(this))
        );

        // Try to bridge the token using the PoS bridge contract
        try
            POS_BRIDGE.depositFor(
                address(this),
                address(token),
                abi.encodePacked(token.balanceOf(address(this)))
            )
        {
            return true;
        } catch {
            return false;
        }
    }

    /**
     * @dev Internal function to handle bridging of ETH.
     * @return success Boolean value indicating if the operation was successful.
     */
    function depositEther() internal returns (bool) {
        // Try to bridge ETH using the PoS bridge contract
        try
            POS_BRIDGE.depositEtherFor{value: address(this).balance}(
                address(this)
            )
        {
            return true;
        } catch {
            return false;
        }
    }

    /**
     * @dev Allows the owner to rescue tokens that cannot be bridged or need to be recovered.
     * @param token The ERC20 token or ETH to rescue.
     * @param destination The address to send the rescued funds to.
     */
    function rescueCrypto(IERC20 token, address destination) external {
        require(
            msg.sender == OWNER_ADDRESS,
            "BridgeRelay: caller must be owner"
        ); // Only allow the owner to perform this action

        if (token == MATIC) {
            // Special handling for MATIC, which cannot be bridged by this contract
            MATIC.safeTransfer(destination, MATIC.balanceOf(address(this)));
        }

        if (token == WETH) {
            // If token is WETH, convert it to ETH by withdrawing
            IERC20Withdrawable(address(WETH)).withdraw(
                WETH.balanceOf(address(this))
            );
        }

        // Attempt to bridge or directly transfer funds to the destination
        if (token == ETHER || token == WETH) {
            if (!depositEther())
                destination.call{value: address(this).balance}("");
        } else if (token != ETHER) {
            if (!depositERC(token))
                token.safeTransfer(destination, token.balanceOf(address(this)));
        }
    }

    /**
     * @dev Fallback function to allow contract to receive ETH.
     */
    receive() external payable {}
}
