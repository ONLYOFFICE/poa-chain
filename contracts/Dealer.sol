pragma solidity ^0.5.0;

import "./math/SafeMath.sol";
import "./utils/Address.sol";

contract Dealer  { 
    using SafeMath for uint256;
    using Address for address;

    mapping (address => address[]) private _dealers;
    mapping (address => mapping (address => mapping(address => uint256))) private allowed;

    event ApprovalDealer(address indexed owner, address indexed spender, address indexed contractAddr, uint256 value);
    event Spend(address indexed owner, address indexed spender, address indexed contractAddr, uint256 value);

    function spend(address tokenHolder, address dealer, uint256 value) public returns(bool) {
        allowed[tokenHolder][dealer][msg.sender] = allowed[tokenHolder][dealer][msg.sender].sub(value);
        
        emit Spend(tokenHolder, dealer, msg.sender, value);

        return true;                  
    }

    function getDealers(address tokenHolder) public view  returns(address[] memory) {
        return _dealers[tokenHolder];
    }

    function checkDealer(address dealer, address tokenHolder) public view returns (bool) {
        for (uint256 index = 0; index < _dealers[tokenHolder].length; index++) {
            if (_dealers[tokenHolder][index] == dealer) {
                return true;
            }
        }

        return false;
    }

    function approve(address dealer, address contractAddr, uint256 value) public returns (bool) {        
        require(dealer != address(0), "");
        assert(contractAddr.isContract());

        allowed[msg.sender][dealer][contractAddr] = value;

        if (!checkDealer(dealer, msg.sender))
            _dealers[msg.sender].push(dealer);

        emit ApprovalDealer(msg.sender, dealer, contractAddr, value);

        return true;
    }

    function allowance(address tokenHolder, address dealer, address contractAddr) public view returns (uint256) {
        return allowed[tokenHolder][dealer][contractAddr];
    }
  
    function increaseApproval(address dealer, address contractAddr, uint addedValue) public returns (bool) {
        require(dealer != address(0), "");      
        assert(contractAddr.isContract());

        allowed[msg.sender][dealer][contractAddr] = allowed[msg.sender][dealer][contractAddr].add(addedValue);

        if (!checkDealer(dealer, msg.sender))
            _dealers[msg.sender].push(dealer);

        emit ApprovalDealer(msg.sender, dealer, contractAddr, allowed[msg.sender][dealer][contractAddr]);

        return true;
    }
    
    function decreaseApproval(address dealer, address contractAddr, uint subtractedValue) public returns (bool) {
        require(dealer != address(0), "");
        assert(contractAddr.isContract());

        allowed[msg.sender][dealer][contractAddr] = allowed[msg.sender][dealer][contractAddr].sub(subtractedValue);
        
        if (!checkDealer(dealer, msg.sender))
            _dealers[msg.sender].push(dealer);

        emit ApprovalDealer(msg.sender, dealer, contractAddr, allowed[msg.sender][dealer][contractAddr]);

        return true;
    }  
}