// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract delegate {


    event Authorized(address indexed owner, address indexed borrower, uint256 amount); 
    event BorrowedToMaiFinance(address indexed depositor, address vault, uint256 amount);
    event WithdrawERC721(address withdrawer, address vault, uint256 tokenID);


    mapping(address => bool) admin;

    constructor() public {
        admin[msg.sender] = true;
        vaultAddress["WETH"] = address(0x98eb27E5F24FB83b7D129D789665b08C258b4cCF); // WETH vault address on ethereum
    }

    // mapping to keep track of the amount borrowed by msg.sender
    // borrower=>vault=>amount borrowed
    mapping(address=> mapping(string=>uint)) public borrowedAmount;

    // mapping to find to who the owner has delegated and how much
    // delegator=>borrower=>amount delegated  
    mapping(address=> mapping(address=>uint)) public hasDelegated; 

    //keep track of the orignil owner adress of the nft vault
    // original_owner => vault name => nft_id
    mapping(address=>mapping(string=>uint256[])) public isOwner;

    // vault name (WETH, WBTC, ...) mapped with the address of the associated contract
    mapping(string => address) vaultAddress;

    

    // ERC721 deposit
    function erc721_deposit(string memory _vault, uint256 _erc721_Id, uint256 _maxAmountToBorrow) public{ // ATTENTION vérifier si le erc 721 est bien défini comme un nft de mai finance
        // check that the msg sender is the owner of the nft
        require(vaultAddress[_vault].ownerOf(_erc721_Id)==msg.sender, "You must be the owner of the token");
        // call safeTransferFrom in the vault contract
        vaultAddress[_vault].safeTransferFrom(msg.sender, address(this), _erc721_Id); // ????? fonctionne ?????
        // check if our contract received the nft
        require(vaultAddress[_vault].ownerOf(_erc721_Id)==address(this), "the ERC721 is not in our contract");
        // add the nft to the mapping isOwner
        isOwner[msg.sender][_vault].push(_erc721_Id);

        // try to borrow the max amount to borrow
        uint256 initialBalance = vaultAddress[_vault].balanceOf(address(this));
        // comment vérifier le montant max à emprunter ?
        // borrow the amount from Qidao
        vaultAddress[_vault].borrowToken(_erc721_Id, _maxAmountToBorrow, _front);
        // check the amount of _vault in our contract
        uint256 finalBalance = vaultAddress[_vault].balanceOf(address(this));
        // check that the amount borrowed is equal or superior to the amount of _vault in our contract
        require(finalBalance-initialBalance>=_maxAmountToBorrow, "the amount borrowed hasn't been received");
        // mappping to keep track of the amount borrowed by msg.sender
        borrowedAmount[msg.sender][_vault] += _maxAmountToBorrow;
        // emit event
        emit BorrowedToMaiFinance(msg.sender, vaultAddress[_vault], _maxAmountToBorrow);
    }


    function erc721_withdraw(string memory _vault, uint256 _erc721_Id, bool withdrawEvenIfBorrowed) public{ // withdrawEvenIfBorrowed : true if msg.sender wants to withdraw even if all the amount borrowed is not repaid by borrower
        // check that the msg sender is the owner of the nft
        bool _isOwner = false;
        for (uint i = 0; i < isOwner[msg.sender][_vault].length - 1; i++) {
            if(isOwner[msg.sender][_vault][i] == _erc721_Id) {_isOwner = true; break;}            
        }
        require(_isOwner, "You must be the owner of the token");
        // check that the nft is in our contract
        require(vaultAddress[_vault].ownerOf(_erc721_Id)==address(this), "the ERC721 is not in our contract");
        
        if(!withdrawEvenIfBorrowed) {
            // check if tokens have been borrowed
            require(borrowedAmount[msg.sender][_vault]==0, "Some tokens have been borrowed. Set withdrawEvenIfBorrowed to true to withdraw the ERC721. If so, the borrower won't be able to repay the tokens borrowed");
        }
        // call safeTransferFrom in the vault contract
        vaultAddress[_vault].safeTransferFrom(address(this), msg.sender, _erc721_Id); // ????? fonctionne ?????
        // check if msg.sender received the nft
        require(vaultAddress[_vault].ownerOf(_erc721_Id)==msg.sender, "You didn't receive the ERC721");
        // emit event
        emit WithdrawERC721(msg.sender, vaultAddress[_vault], _erc721_Id);
    }


    // fonction pour approuver la délagation
    // voir comment remplacer les owner par msg.sender sur remix 
    function approveDelegation(address _owner, address _borrower, uint _amount) public { // ATTENTION : si on reduit la quantité que l'emprunteur peut emprunter, il peut y avoir une sorte de dette négative
    }



    // borrow
    function borrow(uint _amount, address _delegator, string memory _vault) public {
    }    


    // add collateral
    function addCollateralToMaiFinance(uint _amount, address _delegator, string memory _vault) public {

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

    function edit_tokenAdress(string memory crypto, address _token) public {
        require(admin[msg.sender], "You are not an admin");
        vaultAddress[crypto] = _token;
    }

}

