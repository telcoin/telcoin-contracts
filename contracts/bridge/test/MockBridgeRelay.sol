// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Withdrawable} from "../interfaces/IERC20Withdrawable.sol";
import {IPOSBridge} from "../interfaces/IPOSBridge.sol";

// TESTING ONLY
contract MockBridgeRelay {
    using SafeERC20 for IERC20;
    // attemped MATIC bridging
    error MATICUnbridgeable();

    //ETHER address
    IERC20 public constant ETHER =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    // WETH address
    IERC20 public WETH;
    //MATIC address
    IERC20 public MATIC;
    // mainnet PoS bridge
    IPOSBridge public POS_BRIDGE;
    // mainnet predicate
    address public PREDICATE_ADDRESS;
    // Owner address
    address public OWNER_ADDRESS;

    // TESTING ONLY
    // CONSTRUCTOR DOES NOT EXIST ON PRODUCITON CONTRACT
    // SEE BridgeRelay.sol
    constructor(
        IERC20 weth,
        IERC20 matic,
        IPOSBridge pos,
        address predicate,
        address owner
    ) {
        WETH = weth;
        MATIC = matic;
        POS_BRIDGE = pos;
        PREDICATE_ADDRESS = predicate;
        OWNER_ADDRESS = owner;
    }

    /**
     * @notice calls Polygon POS bridge for deposit
     * @dev the contract is designed in a way where anyone can call the function without risking funds
     * @dev MATIC cannot be bridged
     * @param token address of the token that is desired to be pushed accross the bridge
     */
    function bridgeTransfer(IERC20 token) external {
        // revert if MATIC is attempted
        if (token == MATIC) revert MATICUnbridgeable();
        // unwrap WETH
        if (token == WETH) {
            IERC20Withdrawable(address(WETH)).withdraw(
                WETH.balanceOf(address(this))
            );
        }

        if (token == ETHER || token == WETH) depositEther();
        else depositERC(token);
    }

    function depositERC(IERC20 token) internal returns (bool) {
        token.forceApprove(PREDICATE_ADDRESS, 0);
        token.safeIncreaseAllowance(
            PREDICATE_ADDRESS,
            token.balanceOf(address(this))
        );
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

    function depositEther() internal returns (bool) {
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
     * @notice helps recover MATIC which cannot be bridged with POS bridge
     * @dev only Owner may make function call
     * @param destination address where funds are returned
     */
    function rescueCrypto(IERC20 token, address destination) external {
        // restrict to owner
        require(
            msg.sender == OWNER_ADDRESS,
            "BridgeRelay: caller must be owner"
        );

        // revert if MATIC is attempted
        if (token == MATIC)
            MATIC.safeTransfer(destination, MATIC.balanceOf(address(this)));
        // unwrap WETH
        if (token == WETH) {
            IERC20Withdrawable(address(WETH)).withdraw(
                WETH.balanceOf(address(this))
            );
        }

        if (token == ETHER || token == WETH) {
            if (!depositEther())
                destination.call{value: address(this).balance}("");
        } else if (token != ETHER)
            if (!depositERC(token))
                token.safeTransfer(destination, token.balanceOf(address(this)));
    }

    /**
     * @notice receives ETHER
     */
    receive() external payable {}
}
