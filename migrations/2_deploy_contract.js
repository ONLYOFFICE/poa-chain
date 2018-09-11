var FilePasswordStorage = artifacts.require("./FilePasswordStorage.sol");
var Developer = artifacts.require("./Developer.sol");
var AdminValidatorList = artifacts.require("./AdminValidatorList.sol");

module.exports = function(deployer) {
  deployer.deploy(FilePasswordStorage);
  deployer.deploy(Developer);
  deployer.deploy(AdminValidatorList);
};