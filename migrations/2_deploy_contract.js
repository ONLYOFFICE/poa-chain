var FilePasswordStorage = artifacts.require("./FilePasswordStorage.sol");
var ECRecovery = artifacts.require("./ECRecovery.sol");

module.exports = function(deployer) {
  deployer.deploy(FilePasswordStorage);
  deployer.deploy(ECRecovery);
};