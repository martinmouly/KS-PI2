// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract delegate {


    event Authorized(address indexed owner, address indexed borrower, uint amount); 
    
    mapping(address => bool) admin;

    constructor() public {
        admin[msg.sender] = true;
    }

    // struct to represent a delegation
    struct Delegate {
        address _owner; 
        address _borrower; 
        uint _amount; 
        bool _authorized; 
    }

    // regarder s'il faut le définir en internal
    // array of all the delegations
    Delegate [] public delegations; 

    // mapping to find to who the owner has delegated and how much
    // delegator=>borrower=>amount delegated  
    mapping(address=> mapping(address=>uint)) public hasDelegated; 

    //keep track of the orignil owner adress of the nft vault
    // original_owner=> nft_id
    mapping(address=>uint256[]) public isOwner;

    //keep track of the amount borrowed
    // borrower=>delegator=>amount borrowed 
    mapping(address=> mapping(address=>uint)) public amountBorrowed; 

    mapping(string => address) vaultAddress;



    

    // fonction pour approuver la délagation
    // voir comment remplacer les owner par msg.sender sur remix 
    function approveDelegation(address _owner, address _borrower, uint _amount) public { // ATTENTION : si on reduit la quantité que l'emprunteur peut emprunter, il peut y avoir une sorte de dette négative

        // we check that the msg sender is the owner of the fund 
        require(_owner==msg.sender, "this address is not the owner of the funds");
        require(_borrower!=address(0), "borrower can't be address(0)");
        require(_borrower!=_owner, "borrower must be different that owner");
        require (_amount>0, "amount borrowed must be superior to 0");
        // need to add the require to check that the owner has deposit collateral and don't use it 

        delegations.push(Delegate(_owner, _borrower, _amount, true)); 
        hasDelegated[_owner][_borrower] = _amount; 
        emit Authorized(_owner, _borrower, _amount); 
    }



    // nft deposit
    function erc721_deposit(address _initialBorrower, uint256 _erc721_Id) public{ // ATTENTION vérifier si le erc 721 est bien défini comme un nft de mai finance
        // call safeTransferFrom
        IERC721(_initialBorrower).safeTransferFrom(msg.sender, address(this), _erc721_Id);
        // add the nft to the mapping isOwner
        isOwner[msg.sender].push(_erc721_Id);
    }



    // emprunter 
    function borrow(uint _amount, address _initialBorrower, address _vault) public {
        // check that the amount borrowed is superior to 0
        require(_amount>0, "amount borrowed must be superior to 0");
        // check that the initial borrower has delegated to the msg.sender
        require(hasDelegated[_initialBorrower][msg.sender]>0, "this borrower has not delegated to you"); // borrow from himself
        // check that the amount already borrowed + new borrow is inferior to the maximal amount delegated
        require(_amount + amountBorrowed[msg.sender][_initialBorrower]<=hasDelegated[_initialBorrower][msg.sender], "the amount borrowed is superior to the amount delegated");
        
        
        // borrow the amount from Qidao
        //_vault.call.value(0 ether)("foo(string,uint256)", "argument 1", "argument2"); // foo = fct du contrat _vault à appeler Quelle value ?
        // add the amount borrowed to the mapping amountBorrowed
        //amountBorrowed[msg.sender][_initialBorrower] += _amount;
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

