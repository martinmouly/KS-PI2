const delegate = artifacts.require("delegate");
const fakeMai = artifacts.require("fakeMai"); 
const FakeVault = artifacts.require("FakeVault"); 

contract("delegate", accounts => {
    
    const borrower = accounts[0]; 
    const delegator = accounts[1]; 

    it("should deploy the contract", async () => {
        const mai = await fakeMai.new("mai","MAI"); 
        assert.isTrue(mai != null, "Mai deployement failed");
        const vault = await FakeVault.new(mai.address, "vault", "VAULT" ); 
        assert.isTrue(vault != null, "Vault deployement failed"); 
        const _delegate = await delegate.new(mai.address, vault.address); 
        assert.isTrue(_delegate!=null, "Delegate deployment failed");  
 
    });
 
    it("should deposit ERC721 token to the delegate contract, user call approve", async () => {
        const mai = await fakeMai.new("mai","MAI"); 
        assert.isTrue(mai != null, "Mai deployement failed");
        const vault = await FakeVault.new(mai.address, "vault", "VAULT" ); 
        assert.isTrue(vault != null, "Vault deployement failed"); 
        const _delegate = await delegate.new(mai.address, vault.address); 
        assert.isTrue(_delegate!=null, "Delegate deployment failed"); 
        

        
        const tokenId = await vault.createVault({from : accounts[0]}); 
        const balance = await vault.balanceOf.call( accounts[0]); 
        assert.isTrue(balance.gt(0), "token mint failed");  
        const approved = await vault.approve(_delegate.address, 0, {from : accounts[0]}).valueOf();
        assert.isTrue(approved.receipt.status, "approved failed"); 
        const deposit = await _delegate.depositErc721(0,"test", {from: accounts[0]}); 
        assert.isTrue(deposit.receipt.status, "deposit failed"); 
        const contract_balance = await vault.balanceOf.call(_delegate.address); 
        assert.isTrue(contract_balance.gt(0), "deposit failed"); 
    });
    
});