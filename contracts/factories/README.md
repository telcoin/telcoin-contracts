# Factory Contracts Overview

This documentation outlines the structure and functionalities of a set of smart contracts for creating and managing upgradeable proxy contracts within the Ethereum ecosystem. These contracts leverage the EIP-1967 standard for upgradeable contracts, OpenZeppelin's secure upgradeable proxy patterns, and a factory pattern for batch creation of proxies.

## Contracts

### `FactoryStorage`

A library that provides utility functions for managing the storage slots specified by EIP-1967. It includes functionalities to set and get the addresses of implementation and proxy contracts adhering to this standard.

#### FactoryStorage-Functions

`getImplementation()`: Returns the current implementation address.

`_setImplementation(address newImplementation)`: Sets a new implementation address.

`getProxy()`: Returns the current proxy address.

`_setProxy(address newProxy)`: Sets a new proxy address.

### `ProxyFactory`

A contract that acts as both a beacon for pointing to the current implementation logic of proxies and a factory for creating new proxy instances. It supports upgradeability and batch deployment of proxies.

#### Key Features

Beacon Functionality: Allows upgrading the implementation logic that all proxies created by the factory will point to.

Factory Functionality: Enables the batch creation of proxies with deterministic addresses using salts and initialization data.

##### Events

`Deployed(address indexed proxy, bytes32 salt)`: Emitted when a new proxy is deployed.

#### ProxyFactory-Functions

`implementation()`: Returns the current implementation address.

`upgradeTo(address newImplementation)`: Upgrades the beacon to a new implementation.

`proxy()`: Returns the address of the proxy contract used for cloning.

`setProxy(address newProxy)`: Sets a new proxy contract address for cloning.

`create(bytes32[] memory salts, bytes[] memory data)`: Creates new proxy instances with specific initialization data.
