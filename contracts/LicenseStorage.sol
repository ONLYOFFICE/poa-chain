pragma solidity ^0.5.0;

import "./ERC20/IERC20.sol";
import "./Dealer.sol";
import "./SolutionList.sol";
import "./PriceList.sol";
import "./math/SafeMath.sol";

contract LicenseStorage {
    using SafeMath for uint256;

    License[] private _licenses;
   
    IERC20 private tokenContract;
    Dealer private dealerContract;
    SolutionList private solutionListContract;
    PriceList private priceListContract;
    
    constructor(
        IERC20 _tokenContract, 
        Dealer _dealerContract, 
        SolutionList _solutionListContract, 
        PriceList _priceListContract
    ) public 
    {
        tokenContract = _tokenContract;
        dealerContract = _dealerContract;
        solutionListContract = _solutionListContract;
        priceListContract = _priceListContract;
    }

    struct License {
        address owner;
        string solution;
        uint256 userCount;
        address[] users;
        uint256 tokenCount; 
        address dealer;
        address tokenHolder;
        address createBy;
        uint256 startDate;        
        uint256 endDate;
        bytes data;        
        bool reclaimedToken; 
        uint256 index;      
    }

    event LicenseGenerate(
        address indexed owner, 
        string solution, 
        uint256 userCount, 
        uint256 tokenCount,       
        address indexed tokenHolder, 
        address indexed dealer, 
        uint256 startDate, 
        uint256 endDate, 
        bytes data
    );

    event ReclaimedToken(address indexed tokenHolder, uint256 tokenCount);
    event AddUserToLicense(uint256 licenseIndex,address indexed user);
    event RemoveUserFromLicense(uint256 licenseIndex, address indexed user);
    
    function addLicense(
        address owner,    
        string memory solution,         
        address tokenHolder, 
        address dealer,  
        uint256 startDate, 
        uint256 endDate,
        uint256 userCount,  
        bytes memory data) 
      public
      returns(bool)
    {
        require(owner != address(0), "");
        require(tokenHolder != address(0), "");
        require(solutionListContract.isExist(solution), "");
        require(startDate >= block.timestamp, "");
        require(endDate >= startDate, "");
        require(data.length > 0, "");

        uint256 tokenCount = priceListContract.getPrice(solution);

        assert(tokenCount > 0);

        if (dealer != address(0))
        {
            require(tokenHolder != address(0), "");
            require(msg.sender == dealer, "");
            require(dealerContract.checkDealer(dealer, tokenHolder), "");

            uint256 tokenAllowance = dealerContract.allowance(tokenHolder, dealer, address(this));

            assert(tokenAllowance >= tokenCount);
            
            dealerContract.spend(tokenHolder, dealer, tokenCount);

            tokenContract.transferFrom(tokenHolder, address(this), tokenCount);
        }
        else
        {
            require(msg.sender == tokenHolder, "");            
            tokenContract.transferFrom(msg.sender, address(this), tokenCount);
        }  

        address[] memory users = new address[](1);
       
        users[0] = owner;

        _licenses.push(License(
            owner, 
            solution, 
            userCount,
            users,
            tokenCount, 
            dealer, 
            tokenHolder,
            msg.sender, 
            startDate,  
            endDate, 
            data, 
            false,
            _licenses.length
        ));
             
        emit LicenseGenerate(owner, solution, userCount, tokenCount, dealer,tokenHolder, startDate, endDate, data);

        return true;
    }

    function getTokenDepositCount(address tokenHolder, bool onlyCanReclaimToken) public view returns(uint256) {
        require(tokenHolder != address(0), "");    

        uint256 tokenCount = 0;     

        for (uint256 index = 0; index < _licenses.length; index++) {
            if (_licenses[index].tokenHolder != tokenHolder) continue;           
            if (_licenses[index].reclaimedToken) continue;
            
            if (onlyCanReclaimToken)
                if (block.timestamp < _licenses[index].endDate) continue; 
            
            tokenCount = tokenCount.add(_licenses[index].tokenCount);       

        }

        return tokenCount;
    }

    function reclaimToken() public returns(uint256) {
        uint256 tokenCount = 0;

        for (uint256 index = 0; index < _licenses.length; index++) {
            if (_licenses[index].tokenHolder != msg.sender) continue;           
            if (_licenses[index].reclaimedToken) continue;
            if (block.timestamp < _licenses[index].endDate) continue;            
            
            _licenses[index].reclaimedToken = true;                   
            tokenCount = tokenCount.add(_licenses[index].tokenCount);          
        }

        if (tokenCount == 0) return 0;
                
        tokenContract.transfer(msg.sender, tokenCount);

        emit ReclaimedToken(msg.sender, tokenCount);

        return tokenCount;
    }
 
    function addUserToLicense(uint256 licenseIndex, address user) public {
        require(user != address(0), "");
        require(_licenses[licenseIndex].index == licenseIndex, "");     
        require(_licenses[licenseIndex].createBy == msg.sender || _licenses[licenseIndex].owner == msg.sender, ""); 
        require(block.timestamp < _licenses[licenseIndex].endDate, "");
        require(_licenses[licenseIndex].users.length < _licenses[licenseIndex].userCount, "");

        License storage license = _licenses[licenseIndex];
        
        for(uint256 index = 0; index < license.users.length; index++)
        {
            if (license.users[index] == user) return;
        }

        license.users.push(user);   

        emit AddUserToLicense(licenseIndex, user);

    }

    function removeUserFromLicense(uint256 licenseIndex, address user) public {
        require(user != address(0), "");
        require(_licenses[licenseIndex].index == licenseIndex, "");     
        require(_licenses[licenseIndex].createBy == msg.sender || _licenses[licenseIndex].owner == msg.sender, ""); 
        require(block.timestamp < _licenses[licenseIndex].endDate, "");

        License storage license = _licenses[licenseIndex];

        for(uint256 index = 0; index < license.users.length; index++)
        {
            if (license.users[index] != user)   continue;

            license.users[index] = license.users[license.users.length - 1];
            
            delete license.users[license.users.length - 1];

            license.users.length--;

            emit RemoveUserFromLicense(licenseIndex, user);

            break;
        }
    }
    
    function getAllLicenseIndex(address user) public view returns(uint256[] memory) {        
        require(user != address(0), "");
       
        uint256[] memory findedIndex;
        uint256 counter = 0;
        
        for(uint256 index = 0; index < _licenses.length; index++)
        {
            if (_licenses[index].owner == user) { 
                findedIndex[counter] = _licenses[index].index;
                counter = counter + 1;

                continue;
            }

            for(uint256 j = 0; j < _licenses[index].users.length; j++)
            {
                if (_licenses[index].users[j] == user)
                {
                    findedIndex[counter] = _licenses[index].index;
                    counter = counter + 1;
                }

                break;                
            }

        }      

        return findedIndex;
    }
   
    function getLicenseByIndex(uint256 licenseIndex) public view
      returns(address,string memory, uint256, address[] memory, uint256, address, address, uint256,uint256, bytes memory, bool, uint256) {
        
        License storage license = _licenses[licenseIndex];

        return (license.owner,
                license.solution,
                license.userCount,
                license.users,
                license.tokenCount,
                license.dealer,
                license.tokenHolder,
                license.startDate,
                license.endDate,
                license.data,
                license.reclaimedToken,
                license.index
            ); 
    }

    function hasActiveLicense(address user) public view returns (bool) {
        require(user != address(0), "");
     
        for(uint256 index = 0; index < _licenses.length; index++)
        {
            License storage license = _licenses[index];

            if (_licenses[index].endDate < block.timestamp) continue;
            if (_licenses[index].reclaimedToken) continue;
          
            for (uint256 j = 0; j < license.users.length; j++) {
                if (license.users[j] != user) continue;

                return true;
            }           
        }

        return false;       
    }
   
     // Fallback function throws when called.
    function() external
    {
        revert("");
    }
}