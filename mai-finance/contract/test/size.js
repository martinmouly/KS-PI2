var delegate = artifacts.require("delegate");

contract('delegate', function(accounts) {
  it("get the size of the contract", function() {
    return delegate.deployed().then(function(instance) {
      var bytecode = instance.constructor._json.bytecode;
      var deployed = instance.constructor._json.deployedBytecode;
      var sizeOfB  = bytecode.length / 2;
      var sizeOfD  = deployed.length / 2;
      console.log("size of bytecode in bytes = ", sizeOfB);
      console.log("size of deployed in bytes = ", sizeOfD);
      console.log("initialisation and constructor code in bytes = ", sizeOfB - sizeOfD);
    });
  });
});