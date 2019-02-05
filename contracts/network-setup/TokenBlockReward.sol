pragma solidity ^0.5.0;

import "./../ERC20/IERC20.sol";
import "./interfaces/IBlockReward.sol";

contract TokenBlockReward is IBlockReward { 
  
  IERC20 private _token;
  address private _systemAddress;

  uint32 private constant _AUTHOR  = 0;
  uint32 private constant _EMPTY_STEP = 2;
  uint32 private constant _EXTERNAL = 3;
  uint256 private _tokenRewardCount = 0;

  modifier onlySystem {
    require(msg.sender == _systemAddress);
    _;
  }

  constructor (IERC20 token, address systemAddress) public {
      _token = token;
      _systemAddress = systemAddress;
  }

  function getTokenRewardCount() public view returns(uint256) {
      return _tokenRewardCount;
  }

  function setTokenRewardCount(uint256 value) public onlySystem {
      _tokenRewardCount = value;
  }  

  function reward(address[] calldata benefactors, uint16[] calldata kind) external onlySystem returns (address[] memory, uint256[] memory) {
    require(benefactors.length == kind.length);
    require(benefactors.length == 1);

    uint256 amount = _token.balanceOf(address(this));
    
    require(amount > 1); 
    require(kind[0] == _AUTHOR);
            
    _token.transfer(benefactors[0], _tokenRewardCount);

    return (benefactors, new uint256[](benefactors.length));
  }
}
