// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./BasePool.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UtopiaRewardPool is BasePool, Ownable {
    constructor(
        address _rewardToken,
        address _nftToken,
        uint256 totalWeight_
    ) BasePool(_rewardToken, _nftToken, totalWeight_) {}

    function addNftWeightage(uint256 _diamond, uint256 _gold, uint256 _silver) external onlyOwner{
        diamondShare = _diamond;
        goldShare = _gold;
        silverShare = _silver;
    }
}
