# AmirX Contracts Overview

This documentation provides insights into the AmirX contract and the ISimplePlugin interface. The system is designed to facilitate DeFi swap operations while incorporating a mechanism for the buyback of fees using collected tokens.

## Contracts

### `ISimplePlugin`

#### ISimplePlugin-Functions

`increaseClaimableBy(address account, uint256 amount)`: Allows increasing the claimable balance of account by amount, indicating rewards or referral fees. Returns a boolean value indicating success.

## `AmirX`

Extends `StablecoinHandler` to provide DeFi swap and fee buyback functionality. The `AmirX` contract integrates with swap aggregators and referral plugins to execute swaps and buybacks, supporting both ERC20 tokens and native POL tokens.

### Key Features

- **DeFi Swaps**: Facilitates DeFi swaps, including token buybacks and fee management.
- **Referral Rewards**: Supports referral fee handling through plugins.
- **Fee Buybacks**: Automates buyback of fees using swap aggregators.
- **Role-Based Access**: Restricts operations to authorized roles such as `SWAPPER_ROLE` and `SUPPORT_ROLE`.

### Events

- Inherits all events from `StablecoinHandler`.

### Functions

- **`swap(address wallet, bool directional, StablecoinSwap memory ss, DefiSwap memory defi)`**  
  Executes a combination of stablecoin and DeFi swaps based on the specified parameters.

- **`defiToStablecoinSwap(address wallet, StablecoinSwap memory ss, DefiSwap memory defi)`**  
  Performs a DeFi swap followed by a stablecoin swap.

- **`stablecoinToDefiSwap(address wallet, StablecoinSwap memory ss, DefiSwap memory defi)`**  
  Executes a stablecoin swap followed by a DeFi swap.

- **`defiSwap(address wallet, DefiSwap memory defi)`**  
  Executes a standalone DeFi swap.

- **`rescueCrypto(ERC20 token, uint256 amount)`**  
  Recovers mistakenly sent crypto assets, supporting both ERC20 and native POL tokens.

---

### Structures

#### StablecoinSwap

- **`liquiditySafe`**: Address used for intermediary stablecoins or `eXYZs` that are not mintable.
- **`destination`**: Recipient address for the target currency.
- **`origin`**: The originating currency.
- **`oAmount`**: The amount of the originating currency.
- **`target`**: The target currency.
- **`tAmount`**: The amount of the target currency.
- **`stablecoinFeeCurrency`**: Currency used to pay fees.
- **`stablecoinFeeSafe`**: Address where the stablecoin fee is deposited.
- **`feeAmount`**: The amount of the fee.

#### DefiSwap

- **`defiSafe`**: Address for depositing fees.
- **`aggregator`**: Address of the swap aggregator or router.
- **`plugin`**: Referral plugin for fee distribution.
- **`feeToken`**: Token used for fees.
- **`referrer`**: Address receiving referral fees.
- **`referralFee`**: Amount of referral fee.
- **`walletData`**: Data for user wallet interaction.
- **`swapData`**: Data for performing the swap.

---

### Usage Scenarios

#### Swapping Stablecoins

The `stablecoinSwap` function ensures seamless exchange of stablecoins or external tokens while verifying the minting and burning constraints.

#### DeFi Swaps with Fee Buybacks

The `defiSwap` function allows for executing swaps using an aggregator, with automated fee buyback and referral rewards handled by the contract.

#### Combined Swaps

The `swap` function enables a mix of stablecoin and DeFi swaps, with directional control for the sequence of operations.

---

### Role Definitions

- **`PAUSER_ROLE`**: Can pause and unpause the contract.
- **`SWAPPER_ROLE`**: Authorized to perform swaps and manage token movements.
- **`MAINTAINER_ROLE`**: Manages updates to token configurations and limits.
- **`SUPPORT_ROLE`**: Allows recovery of mistakenly sent tokens.