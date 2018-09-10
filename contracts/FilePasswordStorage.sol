pragma solidity ^0.4.24;

/**
 * @title FilePasswordStorage
 */
contract FilePasswordStorage {
    constructor () public {
       
    }

    mapping (bytes32 => mapping(address => bytes)) files;

    function get(bytes32 _fileHash) 
      public 
      view 
      returns(bytes) 
    {
        return files[_fileHash][msg.sender];
    }

    function add(bytes32 _fileHash, address _signer, bytes _pwdSig) 
      public 
    {
        require(_fileHash != 0x0, "File hash require");
        require(_pwdSig.length != 0, "Encrypted file password require");
        require(_signer != address(0), "Signer field require");
        require(files[_fileHash][_signer].length == 0, "require");

        files[_fileHash][_signer] = _pwdSig;
    }

    function remove(bytes32 _fileHash) 
      public 
    {
        delete files[_fileHash][msg.sender];
    }
}
