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

An abstract contract that handles the minting, burning, and swapping of stablecoins. It manages interactions between stablecoins and external tokens (`eXYZ`) while incorporating strict controls on minting and burning limits.

#### Key Features

- **Stablecoin Swaps**: Facilitates swapping between different stablecoins and external tokens.
- **Minting and Burning**: Enforces limits for minting and burning of external tokens.
- **Role-Based Access Control**: Restricts sensitive operations to authorized roles (e.g., `SWAPPER_ROLE`, `PAUSER_ROLE`, `MAINTAINER_ROLE`).
- **Pausable Operations**: Ensures contract functionality can be paused and resumed as needed.

#### Events

- `XYZUpdated(address token, bool validity, uint256 max, uint256 min)`: Emitted when the configuration for an external `eXYZ` token is updated.

#### Functions

- **`stablecoinSwap(address wallet, StablecoinSwap memory ss)`**  
  Initiates a stablecoin swap, validating the swap parameters and executing the operation.

- **`isXYZ(address token)`**  
  Checks if a token is a valid external `eXYZ` token.

- **`getMaxLimit(address token)`**  
  Retrieves the maximum supply limit for a given token.

- **`getMinLimit(address token)`**  
  Retrieves the minimum supply limit for a given token.

- **`UpdateXYZ(address token, bool validity, uint256 maxLimit, uint256 minLimit)`**  
  Updates the validity and supply limits of an external `eXYZ` token.

- **`pause()`**  
  Pauses the contract's operations.

- **`unpause()`**  
  Resumes the contract's operations.