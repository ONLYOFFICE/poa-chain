pragma solidity ^0.5.0;

import "./access/roles/AdminRole.sol";

contract SolutionList is AdminRole {
    
    string[] private _items;    
    
    event SolutionAdd(string solution);
    event SolutionRemoved(string solution);

    function getCount() public view returns(uint256) {
        return _items.length;
    }

    function getItem(uint256 index) public view returns(string memory) {
        require(index < _items.length, "Index out of range");

        return _items[index];
    }

    function isExist(string memory solution) public view returns(bool) {
        for (uint256 index = 0; index < _items.length; index++) {
            if (keccak256(bytes(_items[index])) == keccak256(bytes(solution)))               
            {
                return true;
            }          
        }

        return false;
    }

    function addSolution(string memory solution) public onlyAdmin {
        _items.push(solution);

        emit SolutionAdd(solution);
    }  

    function removeSolution(string memory solution) public onlyAdmin returns(bool) {
        for (uint256 index = 0; index < _items.length; index++) {
            if (keccak256(bytes(_items[index])) == keccak256(bytes(solution)))               
            {
                _items[index] = _items[_items.length - 1];

                delete _items[_items.length - 1];
                
                _items.length--;

                emit SolutionRemoved(solution);

                return true;
            }
        }

        return false;
    }
}