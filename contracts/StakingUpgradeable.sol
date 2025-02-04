// SPDX-License-Identifier: AGPL-3.0-only
// ERC20 Extensions v1.1.3
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "erc20-extensions/contracts-upgradeable/lib/SafeMathUpgradeable.sol";

contract StakingUpgradeable is ERC20Upgradeable {
    using SafeMathUintUpgradeable for uint256;
    using SafeMathIntUpgradeable for int256;

    uint256 private constant MAX_UINT256 = type(uint256).max;
    // allows to distribute small amounts of ETH correctly
    uint256 private constant MAGNITUDE = 10 ** 40;

    IERC20Upgradeable public token;
    uint256 private _magnifiedRewardPerShare;
    mapping(address => int256) private _magnifiedRewardCorrections;
    mapping(address => uint256) public claimedRewards;

    uint256 private _totalStaked = 0;

    function __Staking_init(
        string memory _name,
        string memory _symbol,
        address underlyingToken
    ) internal onlyInitializing {
        __ERC20_init(_name, _symbol);
        token = IERC20Upgradeable(underlyingToken);
    }

    /// @notice when the smart contract receives ETH, register payment
    /// @dev can only receive ETH when tokens are staked
    receive() external payable virtual {
        require(totalSupply() > 0, "NO_TOKENS_STAKED");
        if (msg.value > 0) {
            _magnifiedRewardPerShare += (msg.value * MAGNITUDE) / totalSupply();
        }
    }

    function _stake(uint256 amount) internal virtual returns (uint256) {
        uint256 share = 0;
        if (totalSupply() > 0) {
            share = (totalSupply() * amount) / _totalStaked;
        } else {
            share = amount;
        }
        _totalStaked += amount;
        _mint(_msgSender(), share);
        return share;
    }

    function _unstake(
        uint256 amount,
        bool claim
    ) internal virtual returns (uint256) {
        if (claim) {
            claimRewards(_msgSender());
        }
        uint256 withdrawnTokens = (amount * _totalStaked) / totalSupply();
        _burn(_msgSender(), amount);
        _totalStaked -= amount;
        claimedRewards[_msgSender()] = 0;
        return withdrawnTokens;
    }

    function claimRewards(address to) public virtual returns (uint256) {
        uint256 claimableRewards = claimableRewardsOf(_msgSender());
        if (claimableRewards > 0) {
            claimedRewards[_msgSender()] += claimableRewards;
            (bool success, ) = to.call{value: claimableRewards}("");
            require(success, "ETH_TRANSFER_FAILED");
        }
        return claimableRewards;
    }

    /// @dev on mint, burn and transfer adjust corrections so that ETH rewards don't change on these events
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // mint
            _magnifiedRewardCorrections[to] -= (_magnifiedRewardPerShare *
                amount).toInt256Safe();
        } else if (to == address(0)) {
            // burn
            _magnifiedRewardCorrections[from] += (_magnifiedRewardPerShare *
                amount).toInt256Safe();
        } else {
            // transfer
            require(_isTransferable(), "TRANSFER_FORBIDDEN");
            int256 magnifiedCorrection = (_magnifiedRewardPerShare * amount)
                .toInt256Safe();
            _magnifiedRewardCorrections[from] += (magnifiedCorrection);
            _magnifiedRewardCorrections[to] -= (magnifiedCorrection);
        }
    }

    function totalRewardsEarned(
        address user
    ) public view virtual returns (uint256) {
        int256 magnifiedRewards = (_magnifiedRewardPerShare * balanceOf(user))
            .toInt256Safe();
        uint256 correctedRewards = (magnifiedRewards +
            _magnifiedRewardCorrections[user]).toUint256Safe();
        return correctedRewards / MAGNITUDE;
    }

    function claimableRewardsOf(
        address user
    ) public view virtual returns (uint256) {
        return totalRewardsEarned(user) - claimedRewards[user];
    }

    function _isTransferable() internal view virtual returns (bool) {
        return false;
    }

    uint256[45] private __gap;
}
