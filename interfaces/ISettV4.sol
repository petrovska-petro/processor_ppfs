// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface ISettV4 {
    function depositFor(address recipient, uint256 amount) external;

    function approveContractAccess(address account) external;
}
