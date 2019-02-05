pragma solidity ^0.5.0;

interface IMetadataRegistry {
	event DataChanged(bytes32 indexed name, string key, string plainKey);

	function getData(bytes32 _name, string calldata _key) external view returns (bytes32);
	function getAddress(bytes32 _name, string calldata _key) external view returns (address);
	function getUint(bytes32 _name, string calldata _key) external view returns (uint);
}

interface IOwnerRegistry {
	event Reserved(bytes32 indexed name, address indexed owner);
	event Transferred(bytes32 indexed name, address indexed oldOwner, address indexed newOwner);
	event Dropped(bytes32 indexed name, address indexed owner);

	function getOwner(bytes32 _name) external view returns (address);
}

interface IReverseRegistry {
	event ReverseConfirmed(string name, address indexed reverse);
	event ReverseRemoved(string name, address indexed reverse);

	function hasReverse(bytes32 _name) external view returns (bool);
	function getReverse(bytes32 _name) external view returns (address);
	function canReverse(address _data) external view returns (bool);
	function reverse(address _data) external view returns (string memory);
}


// sha3("service_transaction_checker) = keccak256 = bytes32  -> 0xd0a6e6c54dbc68db5db3a091b171a77407ff7ccf
//
//