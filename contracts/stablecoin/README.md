# Stablecoin Contracts Overview

This documentation covers two smart contracts developed for Telcoin, aimed at creating and managing a stablecoin ecosystem. The Stablecoin contract implements ERC20 standard functionalities with additional features for minting, burning, and blacklisting, ensuring compliance and security. The StablecoinHandler contract abstracts the management of stablecoin swaps, conversions, and the regulation of token supplies.

## Contracts

### `Stablecoin`

An advanced ERC20 token designed for stability, pegged to a fiat currency. It includes functionalities for minting and burning tokens, with a built-in mechanism for blacklisting addresses to prevent misuse.

#### Key Stablecoin Features

Minting and burning by authorized roles.

Blacklisting functionality to restrict transactions from specific addresses.

Customizable decimal places for token precision.

##### Stablecoin-Events

`ImplementationUpdated(address previousImplementation, address newImplementation)`: Emitted when the contract's implementation is updated.

`ProxyUpdated(address previousProxy, address newProxy)`: Emitted when the contract's proxy address is updated.

#### Stablecoin-Functions

`initialize(string memory name_, string memory symbol_, uint8 decimals_)`: Sets up the stablecoin with its name, symbol, and decimal precision. This is only callable once upon deployment through a proxy.

`decimals()`: Returns the number of decimals used to get its user representation. Overridden to use a customizable value.

`mint(uint256 value)`: Mints value amount of tokens to the caller's account, restricted to addresses with MINTER_ROLE.

`mintTo(address account, uint256 value)`: Mints value amount of tokens to a specified account, also restricted to MINTER_ROLE.

`burn(uint256 value)`: Burns value amount of tokens from the caller's account, restricted to BURNER_ROLE.

`burnFrom(address account, uint256 value)`: Burns value amount of tokens from a specified account, deducting from the caller's allowance. This function is also restricted to BURNER_ROLE.

`erc20Rescue(ERC20PermitUpgradeable token, address destination, uint256 amount)`: Allows the rescue of ERC20 tokens accidentally sent to the contract, restricted to SUPPORT_ROLE.

### `StablecoinHandler`

A contract for managing the operations related to stablecoins, including swapping between different stablecoin types and converting to/from external XYZ tokens.

#### Key StablecoinHandler Features

Swap functionality to exchange between different stablecoins or external XYZ tokens.

Conversion operations to handle the minting and burning processes during token swaps.

Role-based access control for managing operations and pausing/unpausing the contract.

##### StablecoinHandler-Events

`XYZUpdated(address token, bool validity, uint256 max, uint256 min)`: Emitted when an external XYZ token's configuration is updated.

#### StablecoinHandler-Functions

`swapAndSend(address wallet, StablecoinSwap memory ss)`: Swaps stablecoins according to specified parameters, enforcing role and pause state. Only callable by SWAPPER_ROLE when not paused.

`convertToEXYZ(address wallet, address safe, StablecoinSwap memory ss)`: Converts assets to an external XYZ token, ensuring the operation is within supply limits and only callable by SWAPPER_ROLE.

`convertFromEXYZ(address wallet, address safe, StablecoinSwap memory ss)`: Converts from an external XYZ token to another asset, observing supply constraints and only callable by SWAPPER_ROLE.

`isXYZ(address token)`: Checks if a given token address is a valid external XYZ token.

`getMaxLimit(address token)`: Retrieves the maximum supply limit for a specified external XYZ token.

`getMinLimit(address token)`: Retrieves the minimum supply limit for a specified external XYZ token.

`UpdateXYZ(address token, bool validity, uint256 maxLimit, uint256 minLimit)`: Updates the configuration for an external XYZ token, including its validity and supply limits. Restricted to MAINTAINER_ROLE.

`pause()`: Pauses all pause-sensitive operations, can only be called by PAUSER_ROLE.

`unpause()`: Unpauses the contract, allowing previously paused operations to resume. Also restricted to PAUSER_ROLE.
