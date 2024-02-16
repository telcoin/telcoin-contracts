# bridge-contracts

`FactoryStorage.sol` is a library contract. It provides proxy safe storage of different values needed for the factory.

`ProxyFactory.sol` is meant to batch proxies and initialize them. All values are updatable. Both `DEPLOYER_ROLE` and `SUPPORT_ROLE` are trusted roles.
