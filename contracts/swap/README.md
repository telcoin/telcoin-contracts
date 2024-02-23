# AmirX Contracts Overview

This documentation provides insights into the AmirX contract and the ISimplePlugin interface. The system is designed to facilitate DeFi swap operations while incorporating a mechanism for the buyback of fees using collected tokens.

## Contracts

### `ISimplePlugin`

#### ISimplePlugin-Functions

`increaseClaimableBy(address account, uint256 amount)`: Allows increasing the claimable balance of account by amount, indicating rewards or referral fees. Returns a boolean value indicating success.

### `AmirX`

Extends the StablecoinHandler contract to implement a DeFi swap and fee buyback mechanism. It manages token swaps and utilizes collected fees for buyback operations, supporting both ERC20 tokens and native MATIC.

#### Key StablecoinHandler Features

`DefiSwap`: Contains details for performing DeFi swaps, including the swap aggregator or router, referral plugin, fee token, referrer, referral fee, and data for wallet interaction and swap execution.

#### StablecoinHandler-Functions

`stablecoinSwap(address wallet, address safe, StablecoinSwap memory ss, DefiSwap memory defi)`: Manages stablecoin swaps and triggers DeFi swap operations based on the provided DefiSwap details.

`defiSwap(address wallet, address safe, DefiSwap memory defi)`: Executes a DeFi swap using the specified DefiSwap details, handling fee dispersal as part of the process.

`rescueCrypto(ERC20 token, uint256 amount)`: Allows for the rescue of crypto assets mistakenly sent to the contract, handling both ERC20 tokens and native MATIC.
