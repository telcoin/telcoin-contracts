# Solidity API

## BridgeRelay

A Telcoin Contract
This contract is meant for forwarding ERC20 and ETH accross the polygon bridge system

### MATICUnbridgeable

```solidity
error MATICUnbridgeable()
```

### ETHER

```solidity
contract IERC20 ETHER
```

### WETH

```solidity
contract IERC20 WETH
```

### MATIC

```solidity
contract IERC20 MATIC
```

### POS_BRIDGE

```solidity
contract IPOSBridge POS_BRIDGE
```

### PREDICATE_ADDRESS

```solidity
address PREDICATE_ADDRESS
```

### OWNER_ADDRESS

```solidity
address OWNER_ADDRESS
```

### bridgeTransfer

```solidity
function bridgeTransfer(contract IERC20 token) external payable
```

calls Polygon POS bridge for deposit

_the contract is designed in a way where anyone can call the function without risking funds
MATIC cannot be bridged_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract IERC20 | address of the token that is desired to be pushed accross the bridge |

### transferERCToBridge

```solidity
function transferERCToBridge(contract IERC20 token) internal
```

pushes token transfers through to the PoS bridge

_this is for ERC20 tokens that are not the matic token
only tokens that are already mapped on the bridge will succeed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract IERC20 | is address of the token that is desired to be pushed accross the bridge |

### erc20Rescue

```solidity
function erc20Rescue(address destination) external
```

helps recover MATIC which cannot be bridged with POS bridge

_only Owner may make function call_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| destination | address | address where funds are returned |

### receive

```solidity
receive() external payable
```

receives ETHER

## IERC20Withdrawable

A Telcoin Contract
withdraw from wrapped token

### withdraw

```solidity
function withdraw(uint256 amount) external
```

_the exit function_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | uint256 balance to be returned |

## IPOSBridge

deposit ETH and ERC20s onto bridge

### depositEtherFor

```solidity
function depositEtherFor(address user) external payable
```

Move ether from root to child chain, accepts ether transfer
Keep in mind this ether cannot be used to pay gas on child chain
Use Matic tokens deposited using plasma mechanism for that

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | address of account that should receive WETH on child chain |

### depositFor

```solidity
function depositFor(address user, address rootToken, bytes depositData) external
```

Move tokens from root to child chain

_This mechanism supports arbitrary tokens as long as its predicate has been registered and the token is mapped_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | address of account that should receive this deposit on child chain |
| rootToken | address | address of token that is being deposited |
| depositData | bytes | bytes data that is sent to predicate and child token contracts to handle deposit |

## MockBridgeRelay

### MATICUnbridgeable

```solidity
error MATICUnbridgeable()
```

### ETHER

```solidity
contract IERC20 ETHER
```

### WETH

```solidity
contract IERC20 WETH
```

### MATIC

```solidity
contract IERC20 MATIC
```

### POS_BRIDGE

```solidity
contract IPOSBridge POS_BRIDGE
```

### PREDICATE_ADDRESS

```solidity
address PREDICATE_ADDRESS
```

### OWNER_ADDRESS

```solidity
address OWNER_ADDRESS
```

### constructor

```solidity
constructor(contract IERC20 weth, contract IERC20 matic, contract IPOSBridge pos, address predicate, address owner) public
```

### bridgeTransfer

```solidity
function bridgeTransfer(contract IERC20 token) external payable
```

calls Polygon POS bridge for deposit

_the contract is designed in a way where anyone can call the function without risking funds
MATIC cannot be bridged_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract IERC20 | address of the token that is desired to be pushed accross the bridge |

### transferERCToBridge

```solidity
function transferERCToBridge(contract IERC20 token) internal
```

pushes token transfers through to the PoS bridge

_this is for ERC20 tokens that are not the matic token
only tokens that are already mapped on the bridge will succeed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract IERC20 | is address of the token that is desired to be pushed accross the bridge |

### erc20Rescue

```solidity
function erc20Rescue(address destination) external
```

helps recover MATIC which cannot be bridged with POS bridge

_only Owner may make function call_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| destination | address | address where funds are returned |

### receive

```solidity
receive() external payable
```

receives ETHER

## TestPOSBridge

### PREDICATE_ADDRESS

```solidity
contract TestPredicate PREDICATE_ADDRESS
```

### constructor

```solidity
constructor(contract TestPredicate predicate) public
```

### depositEtherFor

```solidity
function depositEtherFor(address user) external payable
```

Move ether from root to child chain, accepts ether transfer
Keep in mind this ether cannot be used to pay gas on child chain
Use Matic tokens deposited using plasma mechanism for that

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | address of account that should receive WETH on child chain |

### depositFor

```solidity
function depositFor(address user, address rootToken, bytes balance) external
```

## TestPredicate

### deposit

```solidity
function deposit(address user, address rootToken, uint256 balance) external
```

## ClonableBeaconProxy

_This contract implements a proxy that gets the implementation address for each call from an {UpgradeableBeacon}.

The beacon address can only be set once during construction, and cannot be changed afterwards. It is stored in an
immutable variable to avoid unnecessary storage reads, and also in the beacon storage slot specified by
https://eips.ethereum.org/EIPS/eip-1967[EIP1967] so that it can be accessed externally.

CAUTION: Since the beacon address can never be changed, you must ensure that you either control the beacon, or trust
the beacon to not upgrade the implementation maliciously.

IMPORTANT: Do not use the implementation logic to modify the beacon storage slot. Doing so would leave the proxy in
an inconsistent state where the beacon storage slot does not match the beacon address._

### initialize

```solidity
function initialize(address beacon, bytes data) external
```

_Initializes the proxy with `beacon`.

If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
will typically be an encoded function call, and allows initializing the storage of the proxy like a Solidity
constructor.

Requirements:

- `beacon` must be a contract with the interface {IBeacon}.
- If `data` is empty, `msg.value` must be zero._

### _implementation

```solidity
function _implementation() internal view virtual returns (address)
```

_Returns the current implementation address of the associated beacon._

### _getBeacon

```solidity
function _getBeacon() internal view virtual returns (address)
```

_Returns the beacon._

### receive

```solidity
receive() external payable
```

## MockClonableBeaconProxy

### initialize

```solidity
function initialize(address beacon, bytes data) external
```

_Initializes the proxy with `beacon`.

If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
will typically be an encoded function call, and allows initializing the storage of the proxy like a Solidity
constructor.

Requirements:

- `beacon` must be a contract with the interface {IBeacon}.
- If `data` is empty, `msg.value` must be zero._

### _implementation

```solidity
function _implementation() internal view virtual returns (address)
```

_Returns the current implementation address of the associated beacon._

### implementation

```solidity
function implementation() public view returns (address)
```

### _getBeacon

```solidity
function _getBeacon() internal view virtual returns (address)
```

_Returns the beacon._

### getBeacon

```solidity
function getBeacon() public view returns (address)
```

### receive

```solidity
receive() external payable
```

## ProxyFactory

A Telcoin Contract
This contract acts as both a beacon and factory batcher for clonable proxies.

### DEPLOYER_ROLE

```solidity
bytes32 DEPLOYER_ROLE
```

### SUPPORT_ROLE

```solidity
bytes32 SUPPORT_ROLE
```

### Deployed

```solidity
event Deployed(address proxy, bytes32 salt)
```

_Emitted when a clone is created._

### initialize

```solidity
function initialize(address admin, address implementation_, address proxy_) external
```

Initializes the contract with admin, implementation, and proxy addresses

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| admin | address | The address to be granted the DEFAULT_ADMIN_ROLE |
| implementation_ | address | The initial implementation address the beacon will point to |
| proxy_ | address | The address of the ClonableBeaconProxy contract |

### implementation

```solidity
function implementation() public view returns (address)
```

Returns the current implementation address the beacon points to

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address of the current implementation contract |

### upgradeTo

```solidity
function upgradeTo(address newImplementation) external
```

Upgrades the beacon to a new implementation

_restricted to SUPPORT_ROLE_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newImplementation | address | The address of the new implementation contract |

### proxy

```solidity
function proxy() public view returns (address)
```

Returns the proxy address used by the factory for creating new clones

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address of the proxy contract |

### setProxy

```solidity
function setProxy(address newProxy) external
```

Sets a new proxy address for creating clones

_restricted to SUPPORT_ROLE_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newProxy | address | The address of the new proxy contract |

### create

```solidity
function create(bytes32[] salts, bytes[] data) external
```

Creates new proxy instances with specified salts and initialization data
* @dev restricted to DEPLOYER_ROLE

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| salts | bytes32[] | An array of salts for deterministic deployment of proxies |
| data | bytes[] | An array of initialization data for each proxy Note: `salts` and `data` arrays must be of the same length, as each salt corresponds to a set of initialization data. |

## FactoryStorage

_This abstract contract provides getters and event emitting update functions for
https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots._

### IMPLEMENTATION_SLOT

```solidity
bytes32 IMPLEMENTATION_SLOT
```

_Storage slot with the address of the current implementation.
This is the keccak-256 hash of "eip1967.telcoin.FactoryStorage.implementation" subtracted by 1._

### PROXY_SLOT

```solidity
bytes32 PROXY_SLOT
```

_Storage slot with the proxy of the contract.
This is the keccak-256 hash of "eip1967.telcoin.FactoryStorage.proxy" subtracted by 1._

### InvalidImplementation

```solidity
error InvalidImplementation(address implementation)
```

_The `implementation` of the proxy is invalid._

### InvalidProxy

```solidity
error InvalidProxy(address proxy)
```

_The `proxy` of the proxy is invalid._

### ImplementationUpdated

```solidity
event ImplementationUpdated(address previousImplementation, address newImplementation)
```

_Emitted when the implementation is updated._

### ProxyUpdated

```solidity
event ProxyUpdated(address previousProxy, address newProxy)
```

_Emitted when the proxy address is updated._

### getImplementation

```solidity
function getImplementation() internal view returns (address)
```

_Returns the current implementation address._

### _setImplementation

```solidity
function _setImplementation(address newImplementation) internal
```

_Stores a new address in the EIP1967 implementation slot._

### getProxy

```solidity
function getProxy() internal view returns (address)
```

_Returns the current proxy.

TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using
the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
`0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`_

### _setProxy

```solidity
function _setProxy(address newProxy) internal
```

_Stores a new address in the EIP1967 proxy slot._

## Stablecoin

A Telcoin Contract

This is an ERC20 standard coin with advanced capabilities to allow for
minting and burning. This coin is pegged to a fiat currency and its value is
intended to reflect the value of its native currency

_Blacklisting has been included to prevent this currency from being used for illicit or nefarious activities_

### DECIMALS_SLOT

```solidity
bytes32 DECIMALS_SLOT
```

_Storage slot with the address of the current implementation.
This is the keccak-256 hash of "eip1967.telcoin.Stablecoin.decimals" subtracted by 1._

### MINTER_ROLE

```solidity
bytes32 MINTER_ROLE
```

### BURNER_ROLE

```solidity
bytes32 BURNER_ROLE
```

### SUPPORT_ROLE

```solidity
bytes32 SUPPORT_ROLE
```

### initialize

```solidity
function initialize(string name_, string symbol_, uint8 decimals_) external
```

initializes the contract

_this function is called with proxy deployment to update state data
uses initializer modifier to only allow one initialization per proxy_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | is a string representing the token name |
| symbol_ | string | is a string representing the token symbol |
| decimals_ | uint8 | is an int representing the number of decimals for the token |

### decimals

```solidity
function decimals() public view returns (uint8)
```

Returns the number of decimal places

### mint

```solidity
function mint(uint256 value) public
```

Mints `value` tokens to the caller's account.

_Only accounts with MINTER_ROLE can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| value | uint256 | The amount of tokens to mint. |

### mintTo

```solidity
function mintTo(address account, uint256 value) public
```

Mints `value` tokens to a specified `account`.

_Only accounts with MINTER_ROLE can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account to which tokens will be minted. |
| value | uint256 | The amount of tokens to mint. |

### burn

```solidity
function burn(uint256 value) public
```

Burns `value` tokens from the caller's account.

_Only accounts with BURNER_ROLE can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| value | uint256 | The amount of tokens to burn. |

### burnFrom

```solidity
function burnFrom(address account, uint256 value) public
```

Burns `value` tokens from a specified `account`, deducting from the caller's allowance.

_Only accounts with BURNER_ROLE can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account from which tokens will be burned. |
| value | uint256 | The amount of tokens to burn. |

### _onceBlacklisted

```solidity
function _onceBlacklisted(address user) internal
```

Overrides Blacklist function to transfer balance of a blacklisted user to the caller.

_This function is called internally when an account is blacklisted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | The blacklisted user whose balance will be transferred. |

### erc20Rescue

```solidity
function erc20Rescue(contract ERC20PermitUpgradeable token, address destination, uint256 amount) external
```

sends tokens accidently sent to contract

_restricted to SUPPORT_ROLE_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract ERC20PermitUpgradeable | currency stuck in contract |
| destination | address | address where funds are returned |
| amount | uint256 | is the amount being transferred |

## StablecoinHandler

A Telcoin Contract

This handles the minting and burning of stablecoins

### StablecoinSwap

```solidity
struct StablecoinSwap {
  address destination;
  address origin;
  uint256 oAmount;
  address target;
  uint256 tAmount;
}
```

### eXYZ

```solidity
struct eXYZ {
  bool validity;
  uint256 maxSupply;
  uint256 minSupply;
}
```

### StablecoinHandlerStorage

```solidity
struct StablecoinHandlerStorage {
  mapping(address => struct StablecoinHandler.eXYZ) _eXYZs;
}
```

### PAUSER_ROLE

```solidity
bytes32 PAUSER_ROLE
```

### SWAPPER_ROLE

```solidity
bytes32 SWAPPER_ROLE
```

### MAINTAINER_ROLE

```solidity
bytes32 MAINTAINER_ROLE
```

### ZeroValueInput

```solidity
error ZeroValueInput(string value)
```

### InvalidMintBurnBoundry

```solidity
error InvalidMintBurnBoundry(address token)
```

### XYZUpdated

```solidity
event XYZUpdated(address token, bool validity, uint256 max, uint256 min)
```

### __StablecoinHandler_init

```solidity
function __StablecoinHandler_init() public
```

### __StablecoinHandler_init_unchained

```solidity
function __StablecoinHandler_init_unchained() public
```

### nonZero

```solidity
modifier nonZero(struct StablecoinHandler.StablecoinSwap ss)
```

Ensures all inputs to a stablecoin swap are non-zero

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| ss | struct StablecoinHandler.StablecoinSwap | The stablecoin swap details including origin, target, and amounts. |

### swapAndSend

```solidity
function swapAndSend(address wallet, struct StablecoinHandler.StablecoinSwap ss) public virtual
```

Swaps and sends stablecoins according to specified parameters, enforcing role and pause state.

_Only callable by addresses with the SWAPPER_ROLE and when the contract is not paused._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | The wallet address from which tokens will be burned. |
| ss | struct StablecoinHandler.StablecoinSwap | The stablecoin swap details, including source, target, and amounts. |

### convertToEXYZ

```solidity
function convertToEXYZ(address wallet, address safe, struct StablecoinHandler.StablecoinSwap ss) public virtual
```

Converts assets to an external XYZ token with specified parameters.

_Ensures the operation is performed according to the roles and pause state, transferring from a wallet to a safe address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | The wallet address from which tokens will be transferred. |
| safe | address | The safe address to receive the origin tokens. |
| ss | struct StablecoinHandler.StablecoinSwap | The stablecoin swap details. |

### convertFromEXYZ

```solidity
function convertFromEXYZ(address wallet, address safe, struct StablecoinHandler.StablecoinSwap ss) public virtual
```

Converts from an external XYZ token to another asset as specified.

_Operates within the constraints of roles and the contract's paused state, facilitating the conversion process._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | The wallet address from which tokens will be burned. |
| safe | address | The safe address from which target tokens will be sent. |
| ss | struct StablecoinHandler.StablecoinSwap | The details of the stablecoin swap operation. |

### isXYZ

```solidity
function isXYZ(address token) public view virtual returns (bool)
```

Checks if a given token address is recognized as a valid external XYZ token.

_Reads from the contract's storage to determine the validity of the token address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | address | The address of the token to check. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool True if the token is a valid external XYZ token, false otherwise. |

### getMaxLimit

```solidity
function getMaxLimit(address token) public view virtual returns (uint256)
```

Retrieves the maximum supply limit for a specified external XYZ token.

_Reads the maximum supply limit set for the token from the contract's storage.
This function provides visibility into the operational constraints of external XYZ tokens,
specifically the upper bound of the token's supply within the system._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | address | The address of the external XYZ token whose maximum supply limit is being queried. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 The maximum supply limit for the specified token. This value represents the upper limit on the total supply of the token that can be managed by the contract. |

### getMinLimit

```solidity
function getMinLimit(address token) public view virtual returns (uint256)
```

Retrieves the minimum supply limit for a specified external XYZ token.

_Reads the minimum supply limit set for the token from the contract's storage.
This function is essential for understanding the operational constraints of external XYZ tokens,
highlighting the lower bound of the token's supply that is considered acceptable within the system._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | address | The address of the external XYZ token whose minimum supply limit is being queried. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 The minimum supply limit for the specified token. This value indicates the minimum amount of the token that should be maintained or is allowable within the contract's management scope. |

### UpdateXYZ

```solidity
function UpdateXYZ(address token, bool validity, uint256 maxLimit, uint256 minLimit) public virtual
```

Updates the configuration for an external XYZ token.

_Modifies the validity status and supply limits of the specified token.
Can only be executed by addresses with the MAINTAINER_ROLE.
This method is crucial for maintaining the operational parameters of external XYZ tokens within the system._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | address | The address of the external XYZ token to update. |
| validity | bool | A boolean indicating whether the token should be considered valid. |
| maxLimit | uint256 | The maximum supply limit for the token. |
| minLimit | uint256 | The minimum supply limit for the token. Emits an `XYZUpdated` event upon successfully updating the token's parameters. |

### pause

```solidity
function pause() external
```

Pauses all pause-sensitive operations within the contract.

_Can only be called by addresses with the PAUSER_ROLE, halting certain functionalities._

### unpause

```solidity
function unpause() external
```

Unpauses the contract, allowing previously paused operations to resume.

_Only callable by addresses with the PAUSER_ROLE, reenabling functionalities halted by pausing._

## AmirX

A Telcoin Contract

_Extends StablecoinHandler to implement a DeFi swap and fee buyback mechanism.
It facilitates token swaps and uses collected fees for buyback operations._

### DefiSwap

```solidity
struct DefiSwap {
  address aggregator;
  contract ISimplePlugin plugin;
  contract ERC20 feeToken;
  address referrer;
  uint256 referralFee;
  bytes walletData;
  bytes swapData;
}
```

### TELCOIN

```solidity
contract ERC20 TELCOIN
```

### MATIC

```solidity
address MATIC
```

### SUPPORT_ROLE

```solidity
bytes32 SUPPORT_ROLE
```

### initialize

```solidity
function initialize() public
```

### stablecoinSwap

```solidity
function stablecoinSwap(address wallet, address safe, struct StablecoinHandler.StablecoinSwap ss, struct AmirX.DefiSwap defi) external payable
```

Handles stablecoin swaps and triggers DeFi swap operations.

_Validates stablecoin swap parameters, performs swaps, and handles DeFi interactions based on provided DefiSwap details._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | Address initiating the swap. |
| safe | address | Safe address for temporary token storage if needed. |
| ss | struct StablecoinHandler.StablecoinSwap | StablecoinSwap structure with swap details. |
| defi | struct AmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### defiSwap

```solidity
function defiSwap(address wallet, address safe, struct AmirX.DefiSwap defi) public payable
```

Performs a DeFi swap using the provided DefiSwap details.

_Executes wallet transaction and fee dispersal as part of the swap process._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | Address initiating the swap. |
| safe | address | Safe address for temporary token storage if needed. |
| defi | struct AmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### _feeDispersal

```solidity
function _feeDispersal(address safe, struct AmirX.DefiSwap defi) internal
```

Handles the dispersal of fees collected during a DeFi swap.

_Executes the buyback of fee tokens and handles referral fees if applicable._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| safe | address | Safe address for receiving the remaining buyback tokens. |
| defi | struct AmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### _buyBack

```solidity
function _buyBack(contract ERC20 feeToken, address aggregator, bytes swapData) internal
```

Performs a token buyback using the collected fees.

_Supports buyback for ERC20 tokens and MATIC, handling the swap via the specified aggregator._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feeToken | contract ERC20 | The token to be bought back. |
| aggregator | address | The swap aggregator address. |
| swapData | bytes | Data required to perform the swap. |

### _verifyStablecoin

```solidity
function _verifyStablecoin(address wallet, address safe, struct StablecoinHandler.StablecoinSwap ss, struct AmirX.DefiSwap defi) internal view
```

Validates the stablecoin swap and DefiSwap parameters before execution.

_Checks for valid wallet and safe addresses, and additional validations based on DefiSwap details._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | Address initiating the swap. |
| safe | address | Safe address for temporary token storage if needed. |
| ss | struct StablecoinHandler.StablecoinSwap | StablecoinSwap structure with swap details. |
| defi | struct AmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### _verifyDefi

```solidity
function _verifyDefi(address, address, struct AmirX.DefiSwap defi) internal pure
```

Performs additional validations for the DefiSwap parameters.

_Ensures feeToken, aggregator, and swapData are valid for buyback operations._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
|  | address |  |
|  | address |  |
| defi | struct AmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### rescueCrypto

```solidity
function rescueCrypto(contract ERC20 token, uint256 amount) public
```

Rescues crypto assets mistakenly sent to the contract.

_Allows for the recovery of both ERC20 tokens and native MATIC sent to the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract ERC20 | The token to rescue. |
| amount | uint256 | The amount of the token to rescue. |

## ISimplePlugin

### increaseClaimableBy

```solidity
function increaseClaimableBy(address account, uint256 amount) external returns (bool)
```

provides rewards

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | the address to get the telcoin |
| amount | uint256 | the telcoin value that is being added |

## MockAmirX

### DefiSwap

```solidity
struct DefiSwap {
  address aggregator;
  contract ISimplePlugin plugin;
  contract ERC20 feeToken;
  address referrer;
  uint256 referralFee;
  bytes walletData;
  bytes swapData;
}
```

### TELCOIN

```solidity
contract ERC20 TELCOIN
```

### MATIC

```solidity
address MATIC
```

### SUPPORT_ROLE

```solidity
bytes32 SUPPORT_ROLE
```

### constructor

```solidity
constructor(contract ERC20 telcoin) public
```

### initialize

```solidity
function initialize() public
```

### stablecoinSwap

```solidity
function stablecoinSwap(address wallet, address safe, struct StablecoinHandler.StablecoinSwap ss, struct MockAmirX.DefiSwap defi) external payable
```

Handles stablecoin swaps and triggers DeFi swap operations.

_Validates stablecoin swap parameters, performs swaps, and handles DeFi interactions based on provided DefiSwap details._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | Address initiating the swap. |
| safe | address | Safe address for temporary token storage if needed. |
| ss | struct StablecoinHandler.StablecoinSwap | StablecoinSwap structure with swap details. |
| defi | struct MockAmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### defiSwap

```solidity
function defiSwap(address wallet, address safe, struct MockAmirX.DefiSwap defi) public payable
```

Performs a DeFi swap using the provided DefiSwap details.

_Executes wallet transaction and fee dispersal as part of the swap process._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | Address initiating the swap. |
| safe | address | Safe address for temporary token storage if needed. |
| defi | struct MockAmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### _feeDispersal

```solidity
function _feeDispersal(address safe, struct MockAmirX.DefiSwap defi) internal
```

Handles the dispersal of fees collected during a DeFi swap.

_Executes the buyback of fee tokens and handles referral fees if applicable._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| safe | address | Safe address for receiving the remaining buyback tokens. |
| defi | struct MockAmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### _buyBack

```solidity
function _buyBack(contract ERC20 feeToken, address aggregator, bytes swapData) internal
```

Performs a token buyback using the collected fees.

_Supports buyback for ERC20 tokens and MATIC, handling the swap via the specified aggregator._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feeToken | contract ERC20 | The token to be bought back. |
| aggregator | address | The swap aggregator address. |
| swapData | bytes | Data required to perform the swap. |

### _verifyStablecoin

```solidity
function _verifyStablecoin(address wallet, address safe, struct StablecoinHandler.StablecoinSwap ss, struct MockAmirX.DefiSwap defi) internal view
```

Validates the stablecoin swap and DefiSwap parameters before execution.

_Checks for valid wallet and safe addresses, and additional validations based on DefiSwap details._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | Address initiating the swap. |
| safe | address | Safe address for temporary token storage if needed. |
| ss | struct StablecoinHandler.StablecoinSwap | StablecoinSwap structure with swap details. |
| defi | struct MockAmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### _verifyDefi

```solidity
function _verifyDefi(address, address, struct MockAmirX.DefiSwap defi) internal view
```

Performs additional validations for the DefiSwap parameters.

_Ensures feeToken, aggregator, and swapData are valid for buyback operations._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
|  | address |  |
|  | address |  |
| defi | struct MockAmirX.DefiSwap | DefiSwap structure with DeFi swap details. |

### rescueCrypto

```solidity
function rescueCrypto(contract ERC20 token, uint256 amount) public
```

Rescues crypto assets mistakenly sent to the contract.

_Allows for the recovery of both ERC20 tokens and native MATIC sent to the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract ERC20 | The token to rescue. |
| amount | uint256 | The amount of the token to rescue. |

### receive

```solidity
receive() external payable
```

## TestAggregator

### _telcoin

```solidity
contract ERC20 _telcoin
```

### constructor

```solidity
constructor(contract ERC20 telcoin_) public
```

### getSwapSelector

```solidity
function getSwapSelector() external pure returns (bytes4)
```

### getMATICSwapSelector

```solidity
function getMATICSwapSelector() external pure returns (bytes4)
```

### swap

```solidity
function swap() external
```

### MATICSwap

```solidity
function MATICSwap() external payable
```

## TestPlugin

### _telcoin

```solidity
contract ERC20 _telcoin
```

### constructor

```solidity
constructor(contract ERC20 telcoin_) public
```

### increaseClaimableBy

```solidity
function increaseClaimableBy(address, uint256 amount) external returns (bool)
```

## TestToken

### _decimals

```solidity
uint8 _decimals
```

### constructor

```solidity
constructor(string name, string symbol, uint8 decimals_, address recipient, uint256 amount) public
```

### decimals

```solidity
function decimals() public view returns (uint8)
```

_Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5.05` (`505 / 10 ** 2`).

Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the default value returned by this function, unless
it's overridden.

NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}._

### mintTo

```solidity
function mintTo(address recipent, uint256 amount) public
```

### deposit

```solidity
function deposit() public payable
```

### withdraw

```solidity
function withdraw(uint256 wad) public
```

### fallback

```solidity
fallback() external payable
```

### receive

```solidity
receive() external payable
```

## TestWallet

### initialize

```solidity
function initialize() external
```

### test

```solidity
function test() external
```

### getTestSelector

```solidity
function getTestSelector() external pure returns (bytes4)
```

### receive

```solidity
receive() external payable
```

### fallback

```solidity
fallback() external
```

## Blacklist

A Telcoin Contract
This contract is meant to allow for the prevention of the interaction of certain addreses

### BlacklistStorage

```solidity
struct BlacklistStorage {
  mapping(address => bool) _blacklist;
}
```

### BLACKLISTER_ROLE

```solidity
bytes32 BLACKLISTER_ROLE
```

### AlreadyBlacklisted

```solidity
error AlreadyBlacklisted(address user)
```

_reverts if the blacklisting of an already blacklisted address is attempted_

### NotBlacklisted

```solidity
error NotBlacklisted(address user)
```

_reverts if the removal of a blacklisting of an address not blacklisted is attempted_

### AddedBlacklist

```solidity
event AddedBlacklist(address user)
```

_emits when address is blacklisted_

### RemovedBlacklist

```solidity
event RemovedBlacklist(address user)
```

_emits when address is removed from blacklist_

### blacklisted

```solidity
function blacklisted(address user) public view returns (bool)
```

returns blacklsit status of address

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool representing blacklist status |

### addBlackList

```solidity
function addBlackList(address user) public virtual
```

updates blacklisted list to include user

_restricted to BLACKLISTER_ROLE_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | blacklisted address |

### removeBlackList

```solidity
function removeBlackList(address user) public virtual
```

updates blacklisted list to remove user

_restricted to BLACKLISTER_ROLE_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | blacklisted address |

### _setBlacklist

```solidity
function _setBlacklist(address user, bool state) internal virtual
```

### _onceBlacklisted

```solidity
function _onceBlacklisted(address user) internal virtual
```

