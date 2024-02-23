// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import {ClonableBeaconProxy} from "../external/openzeppelin/ClonableBeaconProxy.sol";
import {FactoryStorage} from "./library/FactoryStorage.sol";

/**
 * @title ProxyFactory
 * @author Amir Shirif
 * @notice A Telcoin Contract
 * @notice This contract acts as both a beacon and factory batcher for clonable proxies.
 */
contract ProxyFactory is AccessControlUpgradeable, IBeacon {
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    bytes32 public constant SUPPORT_ROLE = keccak256("SUPPORT_ROLE");

    /**
     * @dev Emitted when a clone is created.
     */
    event Deployed(address indexed proxy, bytes32 salt);

    /************************************************
     *   initializer
     ************************************************/

    /**
     * @notice Initializes the contract with admin, implementation, and proxy addresses
     * @param admin The address to be granted the DEFAULT_ADMIN_ROLE
     * @param implementation_ The initial implementation address the beacon will point to
     * @param proxy_ The address of the ClonableBeaconProxy contract
     */
    function initialize(
        address admin,
        address implementation_,
        address proxy_
    ) external initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        FactoryStorage._setImplementation(implementation_);
        FactoryStorage._setProxy(proxy_);
    }

    /************************************************
     *   Beacon Functions
     ************************************************/

    /**
     * @notice Returns the current implementation address the beacon points to
     * @return The address of the current implementation contract
     */
    function implementation() public view override returns (address) {
        return FactoryStorage.getImplementation();
    }

    /**
     * @notice Upgrades the beacon to a new implementation
     * @dev restricted to SUPPORT_ROLE
     * @param newImplementation The address of the new implementation contract
     */
    function upgradeTo(
        address newImplementation
    ) external onlyRole(SUPPORT_ROLE) {
        FactoryStorage._setImplementation(newImplementation);
    }

    /************************************************
     *   factory Functions
     ************************************************/

    /**
     * @notice Returns the proxy address used by the factory for creating new clones
     * @return The address of the proxy contract
     */
    function proxy() public view returns (address) {
        return FactoryStorage.getProxy();
    }

    /**
     * @notice Sets a new proxy address for creating clones
     * @dev restricted to SUPPORT_ROLE
     * @param newProxy The address of the new proxy contract
     */
    function setProxy(address newProxy) external onlyRole(SUPPORT_ROLE) {
        FactoryStorage._setProxy(newProxy);
    }

    /**
     * @notice Creates new proxy instances with specified salts and initialization data
     * * @dev restricted to DEPLOYER_ROLE
     * @param salts An array of salts for deterministic deployment of proxies
     * @param data An array of initialization data for each proxy
     * Note: `salts` and `data` arrays must be of the same length, as each salt corresponds to a set of initialization data.
     */
    function create(
        bytes32[] memory salts,
        bytes[] memory data
    ) external onlyRole(DEPLOYER_ROLE) {
        require(
            salts.length == data.length,
            "ProxyFactory: array length mismatch"
        );

        for (uint256 i; i < salts.length; i++) {
            address clone = Clones.cloneDeterministic(proxy(), salts[i]);

            ClonableBeaconProxy(payable(clone)).initialize(
                address(this),
                data[i]
            );
            emit Deployed(clone, salts[i]);
        }
    }
}
