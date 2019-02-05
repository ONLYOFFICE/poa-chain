pragma solidity ^0.5.0;

import "./interfaces/ICertifier.sol";
import "./../access/roles/AdminRole.sol";

contract ServiceTransactionChecker is ICertifier, AdminRole {
    struct Certification {
        bool active;
    }

    mapping (address => Certification) certs;   
  
    modifier onlyCertified(address _who) {
        require(certs[_who].active, "");
        _;
    }

    function certify(address _who) external onlyAdmin {
        certs[_who].active = true;
        emit Confirmed(_who);
    }

    function revoke(address _who) external onlyAdmin onlyCertified(_who) {
        certs[_who].active = false;
        emit Revoked(_who);
    }   

    function certified(address _who) external view returns (bool) {
        return certs[_who].active;
    }
}