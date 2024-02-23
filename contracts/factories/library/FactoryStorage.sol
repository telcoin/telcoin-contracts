// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 */
library FactoryStorage {
    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.telcoin.FactoryStorage.implementation" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x99096fb0ea9a5b21bc496837ce83df7837ace2560621a8efb0ba3e8708d64e6e;

    /**
     * @dev Storage slot with the proxy of the contract.
     * This is the keccak-256 hash of "eip1967.telcoin.FactoryStorage.proxy" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant PROXY_SLOT =
        0xb4b1a784ab5160533fe66a9d194039438e1b26d1332887a9a714573fcc21e5d5;

    /**
     * @dev The `implementation` of the proxy is invalid.
     */
    error InvalidImplementation(address implementation);

    /**
     * @dev The `proxy` of the proxy is invalid.
     */
    error InvalidProxy(address proxy);

    /**
     * @dev Emitted when the implementation is updated.
     */
    event ImplementationUpdated(
        address previousImplementation,
        address newImplementation
    );

    /**
     * @dev Emitted when the proxy address is updated.
     */
    event ProxyUpdated(address previousProxy, address newProxy);

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) internal {
        if (newImplementation.code.length == 0) {
            revert InvalidImplementation(newImplementation);
        }
        StorageSlot
            .getAddressSlot(IMPLEMENTATION_SLOT)
            .value = newImplementation;
    }

    /**
     * @dev Returns the current proxy.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using
     * the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function getProxy() internal view returns (address) {
        return StorageSlot.getAddressSlot(PROXY_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 proxy slot.
     */
    function _setProxy(address newProxy) internal {
        if (newProxy == address(0)) {
            revert InvalidProxy(address(0));
        }
        StorageSlot.getAddressSlot(PROXY_SLOT).value = newProxy;
    }
}
