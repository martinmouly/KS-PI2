// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//contract avec les adresses du mainnet ETHEREUM !!!!!!!
contract delegate {


    event BorrowedToMaiFinance(address indexed depositor, address vault, uint256 amount);
    event WithdrawERC721(address withdrawer, address vault, uint256 tokenID);

    event Approved(address indexed owner, address indexed borrower, uint amount, address vault); 
    event PayToMayFinance(uint amount,uint tokenid, address vault); 
    event Borrowed(uint amount, address delagator,address vault); 
    event RepaidToOurContract(uint amount, address borrower, address vault);

// mapping to know who is admin
    mapping(address => bool) admin;

    address maiEth = address(0x8D6CeBD76f18E1558D4DB88138e2DeFB3909fAD6); //mini matic on eth address  PK LE NOM MAIETH ??
    constructor() public {
        admin[msg.sender] = true;
        vaultAddress["WETH"] = address(0x98eb27E5F24FB83b7D129D789665b08C258b4cCF); // WETH vault address on ethereum
        vaultAddress["WBTC"] = address(0x8C45969aD19D297c9B85763e90D0344C6E2ac9d1); // WBTC vault address on ethereum
    }

    
    //      vocabulary :
    // delegator : the owner initial of the nft, he deposited tokens in a vault and has deposited the nft on our contract. He can delegate his nft to a borrower
    // borrower : the person who has been delegated funds by the delegator. He can borrow tokens and repay the tokens


    // mapping to keep track of the amount borrowed by msg.sender
    // borrower=>vault=>amount borrowed
    mapping(address=> mapping(string=>uint)) public borrowedAmount;

    // mapping to find to who the owner has delegated and how much
    // delegator=>borrower=>vault=>amount delegated  
    mapping(address=> mapping(address=>mapping(string=>uint))) public hasDelegated; 

    //keep track of the orignil owner adress of the nft vault
    // original_owner => vault name => nft_id
    mapping(address=>mapping(string=>uint256[])) public isOwner;

    // vault name (WETH, WBTC, ...) mapped with the address of the associated mai-finance vault contract
    mapping(string => address) vaultAddress;

    // token name (WETH, WBTC, ...) mapped with the address of their contract
    mapping(string => address) tokenAddress;
    

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

    // ERC721 withdraw
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
        else{
            // check who are the borrowers and how much they have borrowed to the delegator in order to remove a proportionnal part of their debt
            address[] memory _borrowers = getBorrowers(msg.sender); // ECRIRE LA FONCTION getBorrowers
        }
        // call safeTransferFrom in the vault contract
        vaultAddress[_vault].safeTransferFrom(address(this), msg.sender, _erc721_Id); // ????? fonctionne ?????
        // check if msg.sender received the nft
        require(vaultAddress[_vault].ownerOf(_erc721_Id)==msg.sender, "You didn't receive the ERC721");
        // remove the nft from the mapping isOwner
        isOwner[msg.sender][_vault].pop(_erc721_Id);
        // check if tokens have been removed from the mapping
        bool _isInMapping = false;
        for (uint i = 0; i < isOwner[msg.sender][_vault].length - 1; i++) {
            if(isOwner[msg.sender][_vault][i] == _erc721_Id) {_isInMapping = true; break;}            
        }
        require(!_isInMapping, "the ERC721 is still in the mapping isOwner");
        // emit event
        emit WithdrawERC721(msg.sender, vaultAddress[_vault], _erc721_Id);
    }

     function approveDelegation(address _owner, address _borrower, uint _amount, string memory _vault) public { // ATTENTION : si on reduit la quantité que l'emprunteur peut emprunter, il peut y avoir une sorte de dette négative
        
        // security check
        require(_owner==msg.sender, "this address is not the owner of the funds");
        require(_borrower!=address(0), "borrower can't be address(0)");
        require(_borrower!=_owner, "borrower must be different that owner");
        require (_amount>0, "amount borrowed must be superior to 0");
        require(vaultAddress[_vault], "the vault doesn't exist"); // demander à nandy si ca marche 

        // update the mapping with the amount authorized 
        hasDelegated[_owner][_borrower][_vault] = _amount; 
        emit Approved(_owner, _borrower, _amount, vaultAddress[_vault]);

    }

    // function to call for the borrower to get the fund 
    function borrow(uint _amount, address _delegator, string memory _vault) public {
        //check that the amount borrow is not superior to the amount delegated 
        require(_amount!=0, "Can't borrow 0 token"); 
        require(_amount<= hasDelegated[_delegator][msg.sender][_vault], "Borrow an amount superior to the amount delegated");

        //call the fonction on the mini matic contract to send the 
        maiEth.transferFrom(address(this),msg.sender,_amount); 
        //+= to prevent someone calling the contract with a small amount to change his debt 
        borrowedAmount[msg.sender][_vault] += _amount; 
        emit Borrowed(_amount, _delegator, vaultAddress[_vault]);
    }    

    // function to allow the borrower to repay his debt 
    function repayToOurContract(uint _amount, address _delegator, string memory _vault) public {
        require(_amount!=0, "Can't repay 0 token"); 
        //check that the amount borrow is not superior to the amount delegated 
        require(_amount <= borrowedAmount[msg.sender][_vault], "Repay an amount superior to the amount borrowed");
        // check that the borrower has enough token to repay
        require(maiEth.balanceOf(msg.sender)>=_amount, "You don't have enough Mai to repay this amount");
        // check the vault exist
        require(vaultAddress[_vault], "the vault doesn't exist"); 
        // Save the amount of Mai in our contract
        uint256 _initialAmount = maiEth.balanceOf(address(this));
        // Call the fonction on the mini matic contract to send the 
        maiEth.transferFrom(msg.sender,address(this),_amount); 
        uint256 _finalAmount = maiEth.balanceOf(address(this));
        require(_finalAmount - _initialAmount >= _amount, "The amount of Mai sent is not the same as the amount of Mai received");
        // Edit the mapping borrowedAmount
        borrowedAmount[msg.sender][_vault] -= _amount; 
        emit RepaidToOurContract(_amount, _delegator, vaultAddress[_vault]);
    }



    // repay to mai finance to deposit collateral 
    function addCollateralToMaiFinance(uint _amount,uint _tokenid, string memory _vault) public{
        vaultAddress[_vault].depositCollateral(_tokenid,_amount); 
        emit PayToMayFinance(_amount, _tokenid, vaultAddress[_vault]);
    }

    
    // view function to get the token id of an address
    // user=> adress that we want to see
    //_vault=> name of the vault (WETH, WBTC)
    function getTokenIdByVault(address user, string calldata _vault) external view{
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

    // edit the address of the qi DAO vault contract associated with _tokenName
    function edit_vaultAdress(string memory _tokenName, address _vault) public {
        require(admin[msg.sender], "You are not an admin");
        vaultAddress[_tokenName] = _vault;
    }

}
