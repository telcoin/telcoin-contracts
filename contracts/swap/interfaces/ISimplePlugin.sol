// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ISimplePlugin is IERC165 {
    /**
     * @notice provides rewards
     * @param account the address to get the telcoin
     * @param amount the telcoin value that is being added
     */
    function increaseClaimableBy(
        address account,
        uint256 amount
    ) external returns (bool);
}
