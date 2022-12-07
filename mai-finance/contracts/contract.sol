// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//contract avec les adresses du mainnet ETHEREUM !!!!!!!
contract delegate {


    event Approved(address indexed owner, address indexed borrower, uint amount, string vault); 
    event PayToMayFinance(uint amount,uint tokenid, string vault); 
    event Borrowed(uint amount, address delagator,string vault); 

    mapping(address => bool) admin;

    address maiEth = address(0x8D6CeBD76f18E1558D4DB88138e2DeFB3909fAD6); //mini matic on eth address 
    constructor() public {
        admin[msg.sender] = true;
        vaultAddress["WETH"] = address(0x98eb27E5F24FB83b7D129D789665b08C258b4cCF); // WETH vault address on ethereum
        vaultAddress["WBTC"] = address(0x8C45969aD19D297c9B85763e90D0344C6E2ac9d1); // WBTC vault address on ethereum
    }

    // mapping to keep track of the amount borrowed by msg.sender
    // borrower=>vault=>amount borrowed
    mapping(address=> mapping(string=>uint)) public borrowedAmount;

    // mapping to find to who the owner has delegated and how much
    // delegator=>borrower=>vault=>amount delegated  
    mapping(address=> mapping(address=>mapping(string=>uint))) public hasDelegated; 

    //keep track of the orignil owner adress of the nft vault
    // original_owner => vault name => nft_id
    mapping(address=>mapping(string=>uint256[])) public isOwner;

    // vault name (WETH, WBTC, ...) mapped with the address of the associated contract
    mapping(string => address) vaultAddress;


    function approveDelegation(address _owner, address _borrower, uint _amount, string _vault) public { // ATTENTION : si on reduit la quantité que l'emprunteur peut emprunter, il peut y avoir une sorte de dette négative
        
        // security check
        require(_owner==msg.sender, "this address is not the owner of the funds");
        require(_borrower!=address(0), "borrower can't be address(0)");
        require(_borrower!=_owner, "borrower must be different that owner");
        require (_amount>0, "amount borrowed must be superior to 0");
        require(vaultAddress[_vault], "the vault doesn't exist"); // demander à nandy si ca marche 

        // update the mapping with the amount authorized 
        hasDelegated[_owner][_borrower][_vault] = _amount; 
        emit Approved(_owner, _borrower, _amount, _vault);

    }



    // function to call for the borrower to get the fund 
    function borrow(uint _amount, address _delegator, string _vault) public {
        //check that the amount borrow is not superior to the amount delegated 
        require(_amount!=0, "Can't borrow 0 token"); 
        require(_amount<= hasDelegated[_delegator][msg.sender][_vault], "Borrow an amount superior to the amount delegated");

        //call the fonction on the mini matic contract to send the 
        maiEth.transferFrom(address(this),msg.sender,_amount); 
        //+= to prevent someone calling the contract with a small amount to change his debt 
        borrowedAmount[msg.sender][_vault] += _amount; 
        emit Borrowed(_amount, _delegator, _vault);
    }    


    // repay to mai finance to deposit collateral 
    function addCollateralToMaiFinance(uint _amount,uint _tokenid, string _vault) public{
        vaultAddress[_vault].depositCollateral(_tokenid,_amount); 
        emit PayToMayFinance(_amount, _tokenid, _vault);
    }
    
    // view function to get the token id of an address
    // user=> adress that we want to see
    //_vault=> name of the vault (WETH, WBTC)
    function getTokenIdByVault(address user, string _vault) external view{
        return isOwner[user][_vault]; 
    }


    // admin functions

    function addAdmin(address _admin) public {
        require(admin[msg.sender], "You are not an admin");
        admin[_admin] = true;
    }

    function isAdmin(address _admin) public view returns(bool) {
        return admin[_admin];
    }

    //comment retirer un admin ?
    function edit_VaultAdress(string memory crypto, address _vault) public {
        require(admin[msg.sender], "You are not an admin");
        vaultAddress[crypto] = _vault;
    }

}