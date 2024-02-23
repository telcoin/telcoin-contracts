// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {Stablecoin, SafeERC20, ERC20PermitUpgradeable} from "../stablecoin/Stablecoin.sol";

/**
 * @title StablecoinHandler
 * @author Amir M. Shirif
 * @notice A Telcoin Contract
 *
 * @notice This handles the minting and burning of stablecoins
 */
abstract contract StablecoinHandler is
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20 for ERC20PermitUpgradeable;

    struct StablecoinSwap {
        // recipient of the target currency
        address destination;
        // the originating currency
        address origin;
        // the amount of currency being provided
        uint256 oAmount;
        // the target currency
        address target;
        // the amount of currency to be provided
        uint256 tAmount;
    }

    struct eXYZ {
        // status of address as stablecoin
        bool validity;
        // the max mint limit
        uint256 maxSupply;
        // the min burn limit
        uint256 minSupply;
    }

    /// @custom:storage-location erc7201:telcoin.storage.StablecoinHandler
    struct StablecoinHandlerStorage {
        mapping(address => eXYZ) _eXYZs;
    }

    // keccak256(abi.encode(uint256(keccak256("erc7201.telcoin.storage.StablecoinHandler")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant StablecoinHandlerStorageLocation =
        0x38361881985b0f585e6124dca158a3af102bffba0feb9c42b0b40825f41a3300;

    function _getStablecoinHandlerStorage()
        private
        pure
        returns (StablecoinHandlerStorage storage $)
    {
        assembly {
            $.slot := StablecoinHandlerStorageLocation
        }
    }

    // Authorized Roles
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant SWAPPER_ROLE = keccak256("SWAPPER_ROLE");
    bytes32 public constant MAINTAINER_ROLE = keccak256("MAINTAINER_ROLE");

    // revert with zero value
    error ZeroValueInput(string value);
    // revert with mint/burn action outside of range
    error InvalidMintBurnBoundry(address token);

    // status change to eXYZ
    event XYZUpdated(address token, bool validity, uint256 max, uint256 min);

    /************************************************
     *   initializers
     ************************************************/

    function __StablecoinHandler_init() public onlyInitializing {
        __StablecoinHandler_init_unchained();
    }

    function __StablecoinHandler_init_unchained() public onlyInitializing {
        __Pausable_init();
    }

    /************************************************
     *   modifiers
     ************************************************/

    /**
     * @notice Ensures all inputs to a stablecoin swap are non-zero
     * @param ss The stablecoin swap details including origin, target, and amounts.
     */
    modifier nonZero(StablecoinSwap memory ss) {
        if (
            ss.destination == address(0) ||
            ss.origin == address(0) ||
            ss.oAmount == 0 ||
            ss.target == address(0) ||
            ss.tAmount == 0
        ) revert ZeroValueInput("SS");
        _;
    }

    /************************************************
     *   supply functions
     ************************************************/

    /**
     * @notice Swaps and sends stablecoins according to specified parameters, enforcing role and pause state.
     * @dev Only callable by addresses with the SWAPPER_ROLE and when the contract is not paused.
     * @param wallet The wallet address from which tokens will be burned.
     * @param ss The stablecoin swap details, including source, target, and amounts.
     */
    function swapAndSend(
        address wallet,
        StablecoinSwap memory ss
    ) public virtual whenNotPaused nonZero(ss) onlyRole(SWAPPER_ROLE) {
        if (
            Stablecoin(ss.origin).totalSupply() - ss.oAmount <
            getMinLimit(ss.origin)
        ) revert InvalidMintBurnBoundry(ss.origin);

        if (
            Stablecoin(ss.target).totalSupply() + ss.tAmount >
            getMaxLimit(ss.target)
        ) revert InvalidMintBurnBoundry(ss.target);

        Stablecoin(ss.origin).burnFrom(wallet, ss.oAmount);
        Stablecoin(ss.target).mintTo(ss.destination, ss.tAmount);
    }

    /**
     * @notice Converts assets to an external XYZ token with specified parameters.
     * @dev Ensures the operation is performed according to the roles and pause state, transferring from a wallet to a safe address.
     * @param wallet The wallet address from which tokens will be transferred.
     * @param safe The safe address to receive the origin tokens.
     * @param ss The stablecoin swap details.
     */
    function convertToEXYZ(
        address wallet,
        address safe,
        StablecoinSwap memory ss
    ) public virtual whenNotPaused nonZero(ss) onlyRole(SWAPPER_ROLE) {
        if (
            Stablecoin(ss.target).totalSupply() + ss.tAmount >
            getMaxLimit(ss.target)
        ) revert InvalidMintBurnBoundry(ss.target);

        ERC20PermitUpgradeable(ss.origin).safeTransferFrom(
            wallet,
            safe,
            ss.oAmount
        );
        Stablecoin(ss.target).mintTo(ss.destination, ss.tAmount);
    }

    /**
     * @notice Converts from an external XYZ token to another asset as specified.
     * @dev Operates within the constraints of roles and the contract's paused state, facilitating the conversion process.
     * @param wallet The wallet address from which tokens will be burned.
     * @param safe The safe address from which target tokens will be sent.
     * @param ss The details of the stablecoin swap operation.
     */
    function convertFromEXYZ(
        address wallet,
        address safe,
        StablecoinSwap memory ss
    ) public virtual whenNotPaused nonZero(ss) onlyRole(SWAPPER_ROLE) {
        if (
            Stablecoin(ss.origin).totalSupply() - ss.oAmount <
            getMinLimit(ss.origin)
        ) revert InvalidMintBurnBoundry(ss.origin);

        Stablecoin(ss.origin).burnFrom(wallet, ss.oAmount);
        ERC20PermitUpgradeable(ss.target).safeTransferFrom(
            safe,
            ss.destination,
            ss.tAmount
        );
    }

    /************************************************
     *   read functions
     ************************************************/

    /**
     * @notice Checks if a given token address is recognized as a valid external XYZ token.
     * @dev Reads from the contract's storage to determine the validity of the token address.
     * @param token The address of the token to check.
     * @return bool True if the token is a valid external XYZ token, false otherwise.
     */
    function isXYZ(address token) public view virtual returns (bool) {
        StablecoinHandlerStorage storage $ = _getStablecoinHandlerStorage();
        return $._eXYZs[token].validity;
    }

    /**
     * @notice Retrieves the maximum supply limit for a specified external XYZ token.
     * @dev Reads the maximum supply limit set for the token from the contract's storage.
     * This function provides visibility into the operational constraints of external XYZ tokens,
     * specifically the upper bound of the token's supply within the system.
     * @param token The address of the external XYZ token whose maximum supply limit is being queried.
     * @return uint256 The maximum supply limit for the specified token. This value represents the
     * upper limit on the total supply of the token that can be managed by the contract.
     */
    function getMaxLimit(address token) public view virtual returns (uint256) {
        StablecoinHandlerStorage storage $ = _getStablecoinHandlerStorage();
        return $._eXYZs[token].maxSupply;
    }

    /**
     * @notice Retrieves the minimum supply limit for a specified external XYZ token.
     * @dev Reads the minimum supply limit set for the token from the contract's storage.
     * This function is essential for understanding the operational constraints of external XYZ tokens,
     * highlighting the lower bound of the token's supply that is considered acceptable within the system.
     * @param token The address of the external XYZ token whose minimum supply limit is being queried.
     * @return uint256 The minimum supply limit for the specified token. This value indicates the
     * minimum amount of the token that should be maintained or is allowable within the contract's management scope.
     */
    function getMinLimit(address token) public view virtual returns (uint256) {
        StablecoinHandlerStorage storage $ = _getStablecoinHandlerStorage();
        return $._eXYZs[token].minSupply;
    }

    /************************************************
     *   support functions
     ************************************************/

    /**
     * @notice Updates the configuration for an external XYZ token.
     * @dev Modifies the validity status and supply limits of the specified token.
     * Can only be executed by addresses with the MAINTAINER_ROLE.
     * This method is crucial for maintaining the operational parameters of external XYZ tokens within the system.
     * @param token The address of the external XYZ token to update.
     * @param validity A boolean indicating whether the token should be considered valid.
     * @param maxLimit The maximum supply limit for the token.
     * @param minLimit The minimum supply limit for the token.
     *
     * Emits an `XYZUpdated` event upon successfully updating the token's parameters.
     */
    function UpdateXYZ(
        address token,
        bool validity,
        uint256 maxLimit,
        uint256 minLimit
    ) public virtual onlyRole(MAINTAINER_ROLE) {
        require(
            maxLimit > minLimit,
            "StablecoinHandler: upperbound must be greater than lowerbound"
        );

        StablecoinHandlerStorage storage $ = _getStablecoinHandlerStorage();
        $._eXYZs[token].validity = validity;
        $._eXYZs[token].maxSupply = maxLimit;
        $._eXYZs[token].minSupply = minLimit;
        emit XYZUpdated(token, validity, maxLimit, minLimit);
    }

    /**
     * @notice Pauses all pause-sensitive operations within the contract.
     * @dev Can only be called by addresses with the PAUSER_ROLE, halting certain functionalities.
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses the contract, allowing previously paused operations to resume.
     * @dev Only callable by addresses with the PAUSER_ROLE, reenabling functionalities halted by pausing.
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}
