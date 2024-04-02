// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

interface IStakingPoolN {
    function initialize(address token) external;

    function totalSupply() external view returns (uint256);
}