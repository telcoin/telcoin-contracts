# Bridge Contracts Overview

This documentation provides an overview and usage guide for a series of Ethereum smart contracts designed for bridging ERC20 tokens and ETH across the Polygon bridge system. These contracts facilitate the withdrawal of wrapped tokens, deposit of ETH and ERC20s onto a bridge, and specifically handle bridging operations with safety checks against MATIC bridging.

## Contracts

### `IERC20Withdrawable`

An interface that defines a withdraw function for wrapped tokens, enabling the return of specified amounts to their original form.

#### Withdrawable-Functions

`withdraw(uint256 amount)`: Withdraws a specified amount of the wrapped token.

### `IPOSBridge`

An interface for depositing ETH and ERC20 tokens onto a bridge, supporting the movement of assets from the root to the child chain.

#### IPOSBridge-Functions

`depositEtherFor(address user)`: Deposits ETH for a specified user, transferring ETH to the child chain as WETH.

`depositFor(address user, address rootToken, bytes calldata depositData)`: Deposits specified ERC20 rootToken for a user, using provided depositData for the deposit process.

### `BridgeRelay`

A contract designed for forwarding ERC20 and ETH across the Polygon bridge system. It includes safety mechanisms and utility functions for a seamless bridging experience.

#### Key Features

Supports ETH and ERC20 token bridging.

Prevents direct MATIC bridging through explicit checks.

Allows unwrapping of WETH to ETH for bridging purposes.

Facilitates ERC20 token approvals and transfers to the bridge.

Includes a rescue function for recovering MATIC tokens.

#### BridgeRelay-Functions

`bridgeTransfer(IERC20 token)`: Bridges specified token across the bridge. Reverts if MATIC is attempted. Handles ETH and ERC20 tokens differently.

`erc20Rescue(address destination)`: Allows the recovery of MATIC tokens by transferring them to a destination address. Restricted to the contract owner.
Getting Started
