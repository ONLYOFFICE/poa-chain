pragma solidity ^0.4.23;

contract AdminValidatorList {
    
    address public owner;
    address constant SYSTEM_ADDRESS = 0xffffffffffffffffffffffffffffffffffffffff;
    address[] public validatorList = [0x0000000000000000000000000000000000000001];
    address[] public pendingList = [0x0000000000000000000000000000000000000001];

    mapping(address => bool) public isAdmin;

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] == true);
        _;
    }

    modifier only_system() {
        require(msg.sender == SYSTEM_ADDRESS);
        _;
    }

    event validatorAdded(address newvalidator);
    event validatorRemoved(address oldvalidator);
    event adminAdded(address newadmin);
    event adminRemoved(address oldadmin);

    /// Issue this log event to signal a desired change in validator set.
    /// This will not lead to a change in active validator set until
    /// finalizeChange is called.
    ///
    /// Only the last log event of any block can take effect.
    /// If a signal is issued while another is being finalized it may never
    /// take effect.
    ///
    /// _parent_hash here should be the parent block hash, or the
    /// signal will not be recognized.
    event InitiateChange(bytes32 indexed _parent_hash, address[] _new_set);
    event ChangeFinalized(address[] current_set);

    constructor() public {
        isAdmin[validatorList[0]] = true;
    }

    /// Get current validator set (last enacted or initial if no changes ever made)
    // Called on every block to update node validator list.
    function getValidators() public view returns (address[] _validators) {
        return validatorList;
    }

    function getPendingValidators() public view returns (address[] _p) {
        return pendingList;
    }

    // Add a validator to the list.
    function addValidator(address validator) public onlyAdmin {
        for (uint i = 0; i < pendingList.length; i++) {
            require(pendingList[i] != validator);
        }

        pendingList.push(validator);
        emit validatorAdded(validator);
        emit InitiateChange(block.blockhash(block.number - 1),pendingList);
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
                    
                    emit validatorRemoved(validator);                    
                    emit InitiateChange(blockhash(block.number - 1),pendingList);
                    
                    break;
                }
            }
        }
        return success;
    }

    // Add an admin.
    function addAdmin(address admin) public onlyAdmin {
        isAdmin[admin] = true;        
        emit adminAdded(admin);
    }

    // Remove an admin.
    function removeAdmin(address admin) public onlyAdmin {
        isAdmin[admin] = false;
        emit adminRemoved(admin);
    }

    /// Called when an initiated change reaches finality and is activated.
    /// Only valid when msg.sender == SUPER_USER (EIP96, 2**160 - 2)
    ///
    /// Also called when the contract is first enabled for consensus. In this case,
    /// the "change" finalized is the activation of the initial set.
    function finalizeChange() public only_system {
        validatorList = pendingList;
        emit ChangeFinalized(validatorList);
    }
}
