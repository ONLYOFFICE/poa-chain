pragma solidity ^0.5.0;

/**
 * @title FilePasswordStorage
 */
contract FilePasswordStorage {
    mapping (bytes32 => mapping(address => bytes)) private _files;

    event FilePasswordAdded(bytes32 indexed fileHash, address indexed signer);
    event FilePasswordRemoved(bytes32 indexed fileHash, address indexed signer);

    function get(bytes32 fileHash) 
      public 
      view 
      returns(bytes memory) 
    {
        return _files[fileHash][msg.sender];
    }

    function add(bytes32 fileHash, address signer, bytes memory pwdSig) 
      public 
    {
        require(fileHash != 0x0, "File hash require");
        require(pwdSig.length != 0, "Encrypted file password require");
        require(signer != address(0), "Signer field require");
        require(_files[fileHash][signer].length == 0, "Encrypted file password already exist for this address");

        _files[fileHash][signer] = pwdSig;

        emit FilePasswordAdded(fileHash, signer);
    }

    function remove(bytes32 fileHash) 
      public 
    {
        require(fileHash != 0x0, "File hash require");
        
        require(_files[fileHash][msg.sender].length == 0, "Encrypted file password doesn't exist");
        
        delete _files[fileHash][msg.sender]; 

        emit FilePasswordRemoved(fileHash, msg.sender);

    }
}
