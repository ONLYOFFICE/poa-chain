pragma solidity ^0.5.0;

import "./access/roles/AdminRole.sol";

contract ProductList is AdminRole {
    Product[] _products;
    
    struct Product {
        uint256 index;
        string name;        
        uint256 defaultPrice;
    }

    

}