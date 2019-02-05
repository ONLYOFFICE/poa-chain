pragma solidity ^0.5.0;

import "./../access/roles/AdminRole.sol";

contract NetworkValidators is AdminRole {
    
    address public owner;
    address constant SYSTEM_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    address[] public validatorList = [0x0000000000000000000000000000000000000001];
    address[] public pendingList = [0x0000000000000000000000000000000000000001];
   
    modifier only_system() {
        require(msg.sender == SYSTEM_ADDRESS);
        _;
    }

    event ValidatorAdded(address indexed newvalidator);
    event ValidatorRemoved(address indexed oldvalidator);

    event InitiateChange(bytes32 indexed _parent_hash, address[] _new_set);
    event ChangeFinalized(address[] current_set);

    constructor() public {
        addAdmin(validatorList[0]);
    }

    function getValidators() public view returns (address[] memory _validators) {
        return validatorList;
    }

    function getPendingValidators() public view returns (address[] memory _p) {
        return pendingList;
    }

    // Add a validator to the list.
    function addValidator(address validator) public onlyAdmin {
        for (uint i = 0; i < pendingList.length; i++) {
            require(pendingList[i] != validator);
        }

        pendingList.push(validator);
        emit ValidatorAdded(validator);
        emit InitiateChange(blockhash(block.number - 1),pendingList);
    }

    // Remove a validator from the list.
    function removeValidator(address validator) public onlyAdmin returns (bool success){
        uint i = 0;
        uint count = pendingList.length;
        success = false;

        // you don't want to leave no validators - can't delete any until you have a minimum of 3.
        // This is in case your 1 remaining node goes down. Leave a safety margin of 2
        if (count > 2) {
            for (i = 0; i < count;i++) {
                if (pendingList[i] == validator) {
                    if (i < pendingList.length-1) {
                        pendingList[i] = pendingList[pendingList.length-1];
                    }

                    pendingList.length--;
                    success = true;
                    
                    emit ValidatorRemoved(validator);                    
                    emit InitiateChange(blockhash(block.number - 1),pendingList);
                    
                    break;
                }
            }
        }
        return success;
    }  
    
    function finalizeChange() public only_system {
        validatorList = pendingList;
        emit ChangeFinalized(validatorList);
    }
}