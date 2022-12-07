var HelloWorld=artifacts.require ("delegate");
module.exports = function(deployer) {
      deployer.deploy(HelloWorld);
}