pragma solidity ^0.5.0;

interface ICertifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);

	function certified(address _who) external view returns (bool);
}