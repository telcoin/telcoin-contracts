# bridge-contracts

`BridgeRelay.sol` is a contract that resides on Ethereum and works with the Polygon POS bridge. It calls the appropriate functions to pass Ether and ERC20 tokens across. MATIC uses a different bridge, and since this bridge cannot mint to smart contracts all bridged MATIC tokens would be lost. The `OWNER_ADDRESS` is a trusted address to assisted with MATIC recovery.

`IPOSBridge.sol` is the interface for the Polygon bridge.

`IERC20Withdrawable.sol` provides the ability to interact with tokens that need to be unwrapped, namely Ether, before bridging.
