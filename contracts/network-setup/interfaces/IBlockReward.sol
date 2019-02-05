pragma solidity ^0.5.0;

interface IBlockReward {
  // produce rewards for the given benefactors, with corresponding reward codes.
  // only callable by `SYSTEM_ADDRESS`
  function reward(address[] calldata benefactors, uint16[] calldata kind) external returns (address[] memory, uint256[] memory);

}