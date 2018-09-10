pragma solidity ^0.4.24;

import "./access/rbac/RBACWithAdmin.sol";

contract Developer is RBACWithAdmin { 
    /// Allowed transaction types mask
    uint32 constant None = 0;
    uint32 constant All = 0xffffffff;
    uint32 constant BasicTransaction = 0x01;
    uint32 constant ContractCall = 0x02;
    uint32 constant ContractCreation = 0x04;
    uint32 constant Private = 0x08;

    string constant ROLE_DEVELOPER = "developer";

    function allowedTxTypes(address _sender) public view returns (uint32)
    {   
        if (hasRole(_sender, ROLE_DEVELOPER) || isAdmin(_sender)) return All;

        return BasicTransaction | ContractCall;
    }

    function addAddressDeveloper(address _developer) 
      onlyAdmin
      public 
    {
        _addRole(_developer, ROLE_DEVELOPER);
    }

    function removeAddressDeveloper(address _developer) 
      onlyAdmin
      public 
    {
        _removeRole(_developer, ROLE_DEVELOPER);    
    }    
}
