// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UtopiaMembership is ERC1155, Ownable {
    using Strings for uint256;

    string public name = "NAME";
    string public symbol = "SYMBOL";
    string private baseURI = "BASE URI/"; 

    uint256 public Diamond = 0;
    uint256 public Gold  = 1;
    uint256 public Silver = 2;
    uint256 public Bronze = 3;
    uint256 public Standard = 5; 

        mapping(uint256 => uint256) private _maxSupply;
        mapping(uint256 => uint256) private _currentSupply;
        mapping(uint256 => uint256) private _price;

    constructor() ERC1155(baseURI) {}

    function mint(uint256 _id, uint256 _amount) external payable{
        require(currentSupply(_id) + _amount <= maxSupply(_id), "Max limit reached");
        require(msg.value == mintPrice(_id) * _amount, "Invalid price sent");

        _mint(msg.sender, _id , _amount, "");
        _currentSupply[_id] +=  _amount;

    }

    function batchMint(address user, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external payable {
        require(ids.length == amounts.length, "Invalid array length");

        uint256 totalPrice;
        for(uint8 indx = 0; indx <ids.length; indx++) {
            totalPrice += (mintPrice(ids[indx]) * amounts[indx]);
        }
        require(msg.value == totalPrice, "Invalid mint price sent");

        _mintBatch(user, ids, amounts, data);
    }

    function addMaxsupply(uint256[] memory ids, uint256[] memory supply) external onlyOwner {
        require(ids.length == supply.length, "Invalid array length");
        
        for(uint8 indx = 0; indx < ids.length; indx++) {
            _maxSupply[ids[indx]] = supply[indx];
        }
    }

    function setMintPrice(uint256[] memory ids, uint256[] memory prices) external onlyOwner {
        require(ids.length == prices.length, "Invalid array length");
        
        for(uint8 indx = 0; indx < ids.length; indx++) {
            _price[ids[indx]] = prices[indx];
        }
    }

    function maxSupply(uint256 id) public view returns(uint256) {
        return _maxSupply[id];
    }

    function currentSupply(uint256 id) public view returns(uint256) {
        return _currentSupply[id];
    }

    function mintPrice(uint256 id) public view returns(uint256) {
        return _price[id];
    }

    function uri(uint256 id) public view override returns(string memory) {
        require(bytes(baseURI).length > 0, "base URI does not exists");
        return string(abi.encodePacked(baseURI, id));
    }

    function withdrawEth(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Not enough balance");
        payable(msg.sender).transfer(amount);
    }
}
