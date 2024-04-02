// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

import "./interfaces/IStakingFactory.sol";
import "./interfaces/IStakingPoolN.sol";
import "./StakingPoolN.sol";
import "./lib/BeaconUpgradeable.sol";
import "./lib/BeaconProxyOptimized.sol";
import "hardhat/console.sol";

contract StakingFactory is IStakingFactory, BeaconUpgradeable {
    error StakingPoolAlreadyExists(address token, address pool);
    event StakingPoolCreated(address indexed token, address indexed pool);
    event LockPeriodUpdated(uint256 lockPeriod, uint256 newLockPeriod);

    // token => staking pool
    mapping(address => address) public stakingPools;
    uint256 public lockPeriod;

    function initialize(
        address implementation_,
        uint256 lockPeriod_
    ) public initializer {
        __Ownable2Step_init();
        __Beacon_init(implementation_);
        lockPeriod = lockPeriod_;
    }

    function createStakingPool(address token) external {
        address pool = stakingPools[token];
        if (pool != address(0)) revert StakingPoolAlreadyExists(token, pool);
        bytes memory bytecode = type(StakingPoolN).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token));
        // bytes32 salt = keccak256(abi.encodePacked(token));
        assembly {
            pool := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        // pool = address(new BeaconProxyOptimized{salt: salt}());
        // console.log('pool' , address(pool));
        StakingPoolN(payable(pool)).initialize(token);
        stakingPools[token] = pool;        
        emit StakingPoolCreated(token, pool);
    }

    function updateLockPeriod(uint256 newLockPeriod) external onlyOwner {
        emit LockPeriodUpdated(lockPeriod, newLockPeriod);
        lockPeriod = newLockPeriod;
    }

    function getPoolForRewardDistribution(
        address token
    ) external view returns (address) {
        address pool = stakingPools[token];
        // console.log('poolAddress', address(pool));
        // console.log('totalsupply',StakingPoolN(payable(pool)).totalSupply());
        if (pool == address(0)) return address(0);
        // console.log(address(pool));
        // return StakingPoolN(payable(pool)).totalSupply() != 0 ? pool : address(0);
        return pool;
    }

    uint256[48] private __gap;
}
