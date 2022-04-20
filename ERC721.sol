// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract UtopiaDapp is ERC721Pausable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    string _name = "NFT NAME";
    string _symbol = "SYMBOL";
    string private _baseUriExtended;
    uint256 private _maxSupply = 10_000;

    uint256 public _pricePerMint;
    uint256 public _mintPhaseLimit;
  
    constructor () ERC721(_name, _symbol) {}

    function mint(uint256 nftAmount) external whenNotPaused payable {
        require(currentSupply() + nftAmount <= _mintPhaseLimit , "max limit reached");
        require(msg.value == _pricePerMint * nftAmount, "insufficient mint price");

        for (uint256 indx = 1; indx <= nftAmount; indx++) {
            _tokenId.increment();
            uint256 tokenId = _tokenId.current();
            _mint(msg.sender , tokenId);
        }
    }

    function currentSupply() public view returns(uint256) {
        return _tokenId.current();
    }

    function withdrawEth(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Not enough balance");
        payable(msg.sender).transfer(amount);
    }

    
    function setBaseURI(string memory baseURI_) external onlyOwner {
        require(bytes(baseURI_).length > 0, "Invalid baseURI_");
        _baseUriExtended = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUriExtended;
    }

    function pause() external whenNotPaused onlyOwner{
        _pause();
    }

    function unpause() external whenPaused onlyOwner{
        _unpause();
    }

    function updatePhase(uint256 _price, uint256 _phaseLimit) external onlyOwner {
        require(currentSupply() + _phaseLimit <= _maxSupply, "Must be less than 10000");
        _pricePerMint = _price;
        _mintPhaseLimit = _phaseLimit;
    }

    function totalSupply() external view returns (uint256){
        return _maxSupply;
    }
}
