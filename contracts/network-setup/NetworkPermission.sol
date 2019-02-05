pragma solidity ^0.5.0;

import "./../access/roles/AdminRole.sol";

contract NetworkPermission is AdminRole {
    struct PeerInfo {
        bytes32 public_low;
        bytes32 public_high;
    }

    mapping(uint256 => PeerInfo) private _peers;
    uint256 private _peersLength;

    event PeerAdded(bytes32 sl, bytes32 sh);
    event PeerRemoved(bytes32 sl, bytes32 sh);

    function addPeer(bytes32 sl, bytes32 sh) 
      public 
      onlyAdmin
    {
        require(sl != 0x0, "Peer low bytes array is empty");       
        require(sh != 0x0, "Peer high bytes array is empty"); 
        require(!hasPeer(sl,sh), "Current peer already exists");

        _peers[_peersLength] = PeerInfo(sl, sh);
        _peersLength++; 

        emit PeerAdded(sl, sh);                         
    }
    
    function hasPeer(bytes32 sl, bytes32 sh) 
        public  
        view
        returns(bool)      
    {
        for (uint256 i = 0; i < _peersLength; i++) {
            PeerInfo storage peer = _peers[i];

            if (sh == peer.public_high && sl == peer.public_low) {
                return true;
            }        
        }

        return false;        
    }

    function removePeer(bytes32 sl, bytes32 sh)
      public 
      onlyAdmin
    {
        uint256 index = 0;
        bool index_found = false;

        for (uint256 i = 0; i < _peersLength; i++) {
            PeerInfo storage peer = _peers[i];

            if (sh == peer.public_high && sl == peer.public_low) {
                index = i;
                index_found = true;
            }         
        }

        if (index_found) {
            delete _peers[index];
            _peersLength--;     

            emit PeerRemoved(sl, sh);
        }
    }

    function connectionAllowed(bytes32 sl, bytes32 sh, bytes32 pl, bytes32 ph) public view returns (bool res) {
        uint256 index1 = 0;
        bool index1_found = false;

        uint256 index2 = 0;
        bool index2_found = false;
        
        for (uint256 i = 0; i < _peersLength; i++) {
            PeerInfo storage peer = _peers[i];

            if (sh == peer.public_high && sl == peer.public_low) {
                index1 = i;
                index1_found = true;
            }

            if (ph == peer.public_high && pl == peer.public_low) {
                index2 = i;
                index2_found = true;
            }
        }

        if (!index1_found || !index2_found) {
            return false;
        }

        return true;
    }
}