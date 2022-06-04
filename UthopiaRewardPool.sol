
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
// total waightage will be 10000
    function addNftWeightage(uint256 _diamond, uint256 _gold, uint256 _silver) external onlyOwner{
        require(_diamond + _gold + _silver == totalNftWeightage, "totalweightage should be equal");
            nftShare[0] = (_silver * 10**18)/silverNfts;
            nftShare[1] = _gold/goldNfts;
            nftShare[2] = _diamond/diamondNfts;
    }
    // owner will pass true if he wants to restrict and false if he want to unrestrict.
    function restrictTokenIdSwap(uint256 _tokenid, bool _state) external onlyOwner returns(bool) {
        restricted[_tokenid] = _state;
        return restricted[_tokenid];
    }

    function setNftsAmount(uint256 _diamond, uint256 _gold, uint256 _silver) external onlyOwner{
        require(_diamond != 0 && _gold != 0 && _silver != 0, "cannot be zero");
        diamondNfts = _diamond;
        goldNfts = _gold;
        silverNfts = _silver;
    }
}
