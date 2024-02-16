// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ISimplePlugin is IERC165 {
    function increaseClaimableBy(
        address account,
        uint256 amount
    ) external returns (bool);
}
