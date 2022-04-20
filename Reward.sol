// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract nftRaward is Context, ReentrancyGuard, Ownable{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public token;
    IERC721 public nftContract;

    uint256 l1Raward = 10;
    uint256 l2Raward = 15;
    uint256 l3Raward = 20;

    uint256 rewardStartTime;
    uint256 rewardAmount;

    constructor(IERC20 _token, IERC721 _nftContract){
        rewardStartTime = block.timestamp;
        token = _token;
        nftContract = _nftContract;
      }

    function claimRaward(uint256 _nftId)
     public 
     nonReentrant 
     {
         require(nftContract.ownerOf(_nftId)  == msg.sender, "caller not owner");
         require(block.timestamp >= rewardStartTime + 30 days);
         if(block.timestamp > rewardStartTime + 60 days){
             rewardStartTime = rewardStartTime + 30 days;
         }
         require(msg.sender != address(0), "Address cannot be 0");
             if (_nftId <= 2000) {
         rewardAmount = l1Raward;
        } else if (_nftId <= 5000) {
         rewardAmount = l2Raward;
        } else if (_nftId <= 10000) {
         rewardAmount = l3Raward;
        } 

        require(rewardAmount<= token.balanceOf(address(this)), "Not enough tokens");
        token.safeTransfer(msg.sender ,rewardAmount);
        
}
    
    function checkRemaningTokens()
    external 
    view
    returns(uint256)
    {
         return token.balanceOf(address(this));
    }

    function withdrawRemaningTokens(address _wallet)
    external
    onlyOwner
    {
        uint256 remaningTokens = token.balanceOf(address(this));
         token.safeTransfer(_wallet , remaningTokens);
        
    }

    function changeReward(uint256 lvl1Reward, uint256 lvl2Reward, uint256 lvl3Reward) 
    external 
    onlyOwner{
        l1Raward = lvl1Reward;
        l2Raward = lvl2Reward;
        l3Raward = lvl3Reward;
    }

    

}
