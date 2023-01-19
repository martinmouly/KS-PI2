var Mai = artifacts.require("fakeMai"); 
var FakeVault = artifacts.require("FakeVault"); 
var Delegate = artifacts.require("delegate"); 

module.exports = (deployer, network, accounts) => {
   deployer.then(async () =>{
    await deployFakeMai(); 
   await deployVault(); 
   await deployDelegate(); 
   await deployRecap(); 
   });
}; 

async function deployFakeMai(deployer, network, accounts){
    mai = await Mai.new("mai", "MAI"); 
}

async function deployVault(){
    vault = await FakeVault.new(mai.address, "VAULT", "vault"); 
}

async function deployDelegate(){
    delegate = await Delegate.new(mai.address, vault.address); 
}

async function deployRecap(deployer, network, accounts) {
	console.log("Mai " + mai.address)
	console.log("Vault " + vault.address)
    console.log("Delegate " + delegate.address)
}