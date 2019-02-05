pragma solidity ^0.5.0;

import "./ERC20/ERC20.sol";
import "./ERC20/ERC20Detailed.sol";
import "./ownership/Ownable.sol";
import "./network-setup/NetworkValidators.sol";
import "./math/SafeMath.sol";
import "./LicenseStorage.sol";

contract Token  is ERC20, ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private constant _NAME = "ONLYOFFICE Token"; 
    string private constant _SYMBOL = "OSD"; 
    uint8 private constant _DECIMALS = 18; 
    uint256 private constant _INITIAL_SUPPLY =  10000;
    address[] private _beneficiaries;
    uint256 private _balanceOfContractPercent = 70;

    NetworkValidators private _networkValidators;
    LicenseStorage private _licenseStorageContract;
        
    constructor () ERC20Detailed(_NAME, _SYMBOL, _DECIMALS) public {
        _mint(msg.sender, _INITIAL_SUPPLY);
        
        _beneficiaries.push(msg.sender);      
    }      

    function init(NetworkValidators networkValidators, LicenseStorage licenseStorageContract) 
      public 
      onlyOwner 
    {
        _networkValidators = networkValidators;
        _licenseStorageContract = licenseStorageContract;
    }

    modifier canMint(uint256 amount) { 
        uint256 totalSupply = totalSupply();
        uint256 threshold = totalSupply.mul(_balanceOfContractPercent).div(100);
        uint256 totalSpend = balanceOf(address(_licenseStorageContract));

        require(totalSpend >= threshold, "");
        require(amount <= threshold, "");

        _;        
    }

    modifier hasMintPermission() {
        address[] memory validators = _networkValidators.getValidators();
        bool isValidator = false;

        for (uint256 index = 0; index < validators.length; index++) {
            if (validators[index] == msg.sender)
            {
                isValidator = true;
                break;
            }
        }
        
        require(isValidator, "");
        
        _;
    }

    function mint(uint256 amount) public hasMintPermission canMint(amount) returns (bool) {
        require(totalSupply().add(amount) > 0, "");
        
        uint256 _beforeMintTotalSupply = totalSupply();

        for (uint256 index = 0; index < _beneficiaries.length; index++) {
            address beneficiary = _beneficiaries[index];

            if (balanceOf(beneficiary) == 0) continue;
            if (beneficiary == address(_licenseStorageContract)) continue;

            uint256 share = _getBeneficiaryShare(beneficiary, amount, _beforeMintTotalSupply);

            _mint(beneficiary, share);  
        }

        uint256 surplus = (_beforeMintTotalSupply.add(amount)).sub(totalSupply());

        if (surplus > 0)
           _mint(msg.sender, surplus);  

        return true;        
    }   

    function _getBeneficiaryShare(address beneficiary, uint256 mintAmount, uint256 beforeMintTotalSupply) private view returns(uint256)
    {
        uint256 deposit = _licenseStorageContract.getTokenDepositCount(beneficiary, false);
        
        uint256 part = balanceOf(beneficiary).add(deposit).mul(100).div(beforeMintTotalSupply);
        uint256 share = part.mul(mintAmount).div(100);

        return share;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        bool result = super.transfer(to, value);

        if (!result) return result;

        bool isBeneficiary = false;

        for (uint256 index = 0; index < _beneficiaries.length; index++) {
            if (_beneficiaries[index] == to) {
                isBeneficiary = true;
                break;
            }
        }

        if (!isBeneficiary)
            _beneficiaries.push(to);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        bool result = super.transferFrom(from, to, value);

        if (!result) return result;

        bool isBeneficiary = false;

        for (uint256 index = 0; index < _beneficiaries.length; index++) {
            if (_beneficiaries[index] == to) {
                isBeneficiary = true;
                break;
            }
        }

        if (!isBeneficiary)
            _beneficiaries.push(to);

        return true;
    }
}