pragma solidity ^0.5.0;

import "./../access/roles/AdminRole.sol";
import "./../LicenseStorage.sol";

contract TransactionPermission is AdminRole { 
    /// Allowed transaction types mask
    uint32 private constant _NONE = 0;
    uint32 private constant _ALL = 0xffffffff;
    uint32 private constant _BASIC_TRANSACTION = 0x01;
    uint32 private constant _CONTRACT_CALL = 0x02;
    uint32 private constant _CONTRACT_CREATION = 0x04;
    uint32 private constant _PRIVATE = 0x08;
    uint32 private _default = _BASIC_TRANSACTION | _CONTRACT_CALL;

    mapping (address => Blacklist) private _blacklist;

    struct Blacklist {
        bool active;
    }

    modifier onlyBlacklisted(address user) {
        require(isBlacklisted(user));
        _;
    }
    
    LicenseStorage private _licenseStorageContract;

    event AddUserToBlacklist(address indexed who);
    event RemoveUserFromBlacklist(address indexed who);
    
    function init(LicenseStorage licenseStorageContract) onlyAdmin public {
        _licenseStorageContract = licenseStorageContract;
    }

    function allowedTxTypes(address sender) public view returns (uint32)
    {   
        if (isAdmin(sender)) return _ALL;

        if (address(_licenseStorageContract) != address(0))
        {
            if (!_licenseStorageContract.hasActiveLicense(sender)) return _NONE;
        }

        if (isBlacklisted(sender)) return _NONE;

        return _default;
    }

    function setDefaultPermission(uint32 value) onlyAdmin public {
        _default = value;
    }

    function isBlacklisted(address user) view public returns (bool) {
        return _blacklist[user].active;
    }

    function addUserToBlacklist(address user) onlyAdmin public {
        _blacklist[user].active = true;
                
        emit AddUserToBlacklist(user);
    }

    function removeUserFromBlacklist(address user) onlyAdmin onlyBlacklisted(user) public {
        _blacklist[user].active = false;
      
        emit RemoveUserFromBlacklist(user);
   }
}