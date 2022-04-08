// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./IAbstractRewards.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

abstract contract AbstractRewards is IAbstractRewards {
    using SafeCast for uint128;
    using SafeCast for uint256;
    using SafeCast for int256;

    /* ========  Constants  ======== */
    uint128 public constant POINTS_MULTIPLIER = type(uint128).max;

    /* ========  Internal Function References  ======== */
//   function(uint256) view returns (uint256) private immutable getNFTWeightage;
    function() view returns (uint256) private immutable getTotalWeightage;

    /* ========  Storage  ======== */
    uint256 public pointsPerShare;
    mapping(uint256 => int256) public pointsCorrection;
    mapping(uint256 => uint256) public withdrawnRewards;

    
    uint256 public diamondShare;
    uint256 public goldShare;
    uint256 public silverShare;
    constructor(
    //    function(uint256) view returns (uint256) getNFTWeightage_,
        function() view returns (uint256) getTotalWeightage_
    ) {
    //    getNFTWeightage = getNFTWeightage_;
        getTotalWeightage = getTotalWeightage_;
    }

    /* ========  Public View Functions  ======== */
    /**
     * @dev Returns the total amount of rewards a given id is able to withdraw.
     * @param _tokenId tokenId of a reward recipient
     * @return A uint256 representing the rewards `_tokenId` can withdraw
     */
    function withdrawableRewardsOf(uint256 _tokenId)
        public
        view
        override
        returns (uint256)
    {
        return cumulativeRewardsOf(_tokenId) - withdrawnRewards[_tokenId];
    }

    /**
     * @notice View the amount of rewards that an tokenId has withdrawn.
     * @param _tokenId The tokenId of a token holder.
     * @return The amount of rewards that `_tokenId` has withdrawn.
     */
    function withdrawnRewardsOf(uint256 _tokenId)
        public
        view
        override
        returns (uint256)
    {
        return withdrawnRewards[_tokenId];
    }

    /**
     * @notice View the amount of rewards that an tokenId has earned in total.
     * @dev accumulativeFundsOf(_tokenId) = withdrawableRewardsOf(_tokenId) + withdrawnRewardsOf(_tokenId)
     * = (pointsPerShare * balanceOf(_tokenId) + pointsCorrection[_tokenId]) / POINTS_MULTIPLIER
     * @param _tokenId The tokenId of a token holder.
     * @return The amount of rewards that `_tokenId` has earned in total.
     */
    function cumulativeRewardsOf(uint256 _tokenId)
        public
        view
        override
        returns (uint256)
    {
        return
            ((pointsPerShare * getNFTWeightage(_tokenId)).toInt256() +
                pointsCorrection[_tokenId]).toUint256() / POINTS_MULTIPLIER;
    }


    
        function getNFTWeightage(uint256 _tokenId) private view returns(uint256){
        if(_tokenId <= 2000){
            return diamondShare;
        }else if(_tokenId <= 5000){
            return goldShare;
        }else{
            return silverShare;
        }
    }

    /* ========  Dividend Utility Functions  ======== */

    /**
     * @notice Distributes rewards to token holders.
     * @dev It reverts if the total shares is 0.
     * It emits the `RewardsDistributed` event if the amount to distribute is greater than 0.
     * About undistributed rewards:
     *   In each distribution, there is a small amount which does not get distributed,
     *   which is `(amount * POINTS_MULTIPLIER) % totalShares()`.
     *   With a well-chosen `POINTS_MULTIPLIER`, the amount of funds that are not getting
     *   distributed in a distribution can be less than 1 (base unit).
     */
    function _distributeRewards(uint256 _amount) internal {
        uint256 shares = getTotalWeightage();
        require(
            shares > 0,
            "AbstractRewards._distributeRewards: total share supply is zero"
        );

        if (_amount > 0) {
            pointsPerShare =
                pointsPerShare +
                ((_amount * POINTS_MULTIPLIER) / shares);
            emit RewardsDistributed(msg.sender, _amount);
        }
    }

    /**
     * @notice Prepares collection of owed rewards
     * @dev It emits a `RewardsWithdrawn` event if the amount of withdrawn rewards is
     * greater than 0.
     */
    function _prepareCollect(uint256 _tokenId) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableRewardsOf(_tokenId);
        if (_withdrawableDividend > 0) {
            withdrawnRewards[_tokenId] =
                withdrawnRewards[_tokenId] +
                _withdrawableDividend;
            emit RewardsWithdrawn(msg.sender, _withdrawableDividend);
        }
        return _withdrawableDividend;
    }
}
