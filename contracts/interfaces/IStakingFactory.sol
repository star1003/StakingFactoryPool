// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

interface IStakingFactory {
    function createStakingPool(address token) external ;
    function updateLockPeriod(uint256 newLockPeriod) external ;
    function getPoolForRewardDistribution(address token) external view returns (address) ; 
}