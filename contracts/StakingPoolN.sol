// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

// import "../interfaces/IStakingPool.sol";
import {StakingUpgradeable} from "./StakingUpgradeable.sol";
import {IERC20MetadataUpgradeable as IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

import "hardhat/console.sol";

contract StakingPoolN is StakingUpgradeable {
    // IStakingFactory public factory;
    uint256 private constant LOCK_PERIOD = 1 minutes; // Tokens are locked for 1 min

    struct StakeInfo {
        uint256 depositedAmount;
        uint256 stakedAmount;
        uint256 lockedTimestamp;
    }

    mapping(address => StakeInfo) public stakeInfo;

    event Restaked(address indexed user, uint256 amount);
    event DepositedWithoutLock(address indexed user, uint256 amount);

    function initialize(address token_) public initializer {
        // factory = IStakingFactory(msg.sender);
        string memory name_ = string.concat("Volted ", IERC20(token_).name());
        string memory symbol_ = string.concat("v", IERC20(token_).symbol());
        __Staking_init(name_, symbol_, token_);
    }

    function deposit(uint256 amount) public returns (uint256) {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.transferFrom(_msgSender(), address(this), amount);
        uint256 balanceAfter = token.balanceOf(address(this));
        amount = balanceAfter - balanceBefore;

        StakeInfo storage stake = stakeInfo[_msgSender()];
        stake.depositedAmount += amount;
        return amount;
    }

    
    function stake(uint256 amount) public returns (uint256) {
        StakeInfo storage stake = stakeInfo[_msgSender()];

        require(
            stake.lockedTimestamp + LOCK_PERIOD <= block.timestamp,
            "Locked"
        );
        require(stake.depositedAmount >= amount, "Insufficient amount");

        if (stake.stakedAmount > 0) {
            _unstake(stake.stakedAmount, true);
        }
        stake.stakedAmount = amount;
        stake.lockedTimestamp = block.timestamp;
        return _stake(amount);
    }

    function withdraw(uint256 amount) public {
        StakeInfo storage stake = stakeInfo[_msgSender()];
        if (stake.lockedTimestamp + LOCK_PERIOD <= block.timestamp) {
            super._unstake(stake.stakedAmount, true);
            stake.stakedAmount = 0;
        }
        require(
            stake.depositedAmount - stake.stakedAmount >= amount,
            "Insufficient amount"
        );

        token.transfer(_msgSender(), amount);
    }

    uint256[49] private __gap;
}
