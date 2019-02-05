pragma solidity ^0.5.0;

import "./access/roles/AdminRole.sol";

contract PriceList is AdminRole  {
    mapping (string => uint256) private _items;

    event PriceAdd(string indexed solution, uint256 tokenCount);
    event PriceRemoved(string indexed solution);

    function setPrice(string memory solution, uint256 tokenCount) public onlyAdmin returns (bool) {
        _items[solution] = tokenCount;
    
        emit PriceAdd(solution, tokenCount);

        return true;
    }

    function getPrice(string memory solution) public view returns (uint256) {
        return _items[solution];
    }    

    function removePrice(string memory solution) public onlyAdmin {
        delete _items[solution];   

        emit PriceRemoved(solution);
    }
}