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
