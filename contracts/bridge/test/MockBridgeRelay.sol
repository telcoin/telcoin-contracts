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
    function bridgeTransfer(IERC20 token) external payable {
        // revert if MATIC is attempted
        if (token == MATIC) revert MATICUnbridgeable();
        // unwrap WETH
        if (token == WETH) {
            IERC20Withdrawable(address(WETH)).withdraw(
                WETH.balanceOf(address(this))
            );
            // transfer ERC20 tokens
        } else if (token != ETHER) {
            transferERCToBridge(token);
            return;
        }
        // transfer ETHER
        POS_BRIDGE.depositEtherFor{value: address(this).balance}(address(this));
    }

    /**
     * @notice pushes token transfers through to the PoS bridge
     * @dev this is for ERC20 tokens that are not the matic token
     * @dev only tokens that are already mapped on the bridge will succeed
     * @param token is address of the token that is desired to be pushed accross the bridge
     */
    function transferERCToBridge(IERC20 token) internal {
        //zero out approvals
        token.forceApprove(PREDICATE_ADDRESS, 0);
        // increase approval to necessary amount
        token.safeIncreaseAllowance(
            PREDICATE_ADDRESS,
            token.balanceOf(address(this))
        );
        //deposit
        POS_BRIDGE.depositFor(
            address(this),
            address(token),
            abi.encodePacked(token.balanceOf(address(this)))
        );
    }

    /**
     * @notice helps recover MATIC which cannot be bridged with POS bridge
     * @dev only Owner may make function call
     * @param destination address where funds are returned
     */
    function erc20Rescue(address destination) external {
        // restrict to woner
        require(
            msg.sender == OWNER_ADDRESS,
            "BridgeRelay: caller must be owner"
        );
        //transfer MATIC
        MATIC.safeTransfer(destination, MATIC.balanceOf(address(this)));
    }

    /**
     * @notice receives ETHER
     */
    receive() external payable {}
}
