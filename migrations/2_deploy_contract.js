var AdminRole = artifacts.require("AdminRole");
var FilePasswordStorage = artifacts.require("FilePasswordStorage");
var Developer = artifacts.require("Developer");
var AdminValidatorList = artifacts.require("AdminValidatorList");
var NetworkPermission = artifacts.require("NetworkPermission");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(AdminRole);
  deployer.link(AdminRole, [Developer,AdminValidatorList,NetworkPermission ]);
  deployer.deploy(FilePasswordStorage);
  deployer.deploy(Developer);
  deployer.deploy(AdminValidatorList);
  deployer.deploy(NetworkPermission);
};