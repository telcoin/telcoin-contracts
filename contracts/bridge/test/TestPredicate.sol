// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//TESTING ONLY
contract TestPredicate {
    function deposit(
        address user,
        address rootToken,
        uint256 balance
    ) external {
        IERC20(rootToken).transferFrom(user, address(this), balance);
    }
}
