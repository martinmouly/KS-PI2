// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//contract avec les adresses du mainnet ETHEREUM !!!!!!!
contract delegate {


    event BorrowedToMaiFinance(address indexed depositor, address vault, uint256 amount);
    event WithdrawERC721(address withdrawer, address vault, uint256 tokenID);

    event Approved(address indexed owner, address indexed borrower, uint amount, address vault); 
    event PayToMayFinance(uint amount,uint tokenid, address vault, bool fromOurContract); // if fromOurContract is true, the amount has been paid by our contract to the borrower, if false, the amount has been paid by the borrower to mai finance through our contract  
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


    // mapping to keep track of the amount borrowed from may finance by our contract in the name of the owner of the nft
    // borrower=>vault=>amount borrowed
    mapping(address=>mapping(string=>uint)) public borrowedAmount;

    // mapping to keep track of  who, the amount and the token borrowed by each borrower from each delegator
    // delegator=>borrower=>vault=>amount borrowed
    mapping(address=>mapping(address=>mapping(string=>uint))) public borrowed;

    // mapping to know the total of tokens that have been borrowed from each delegator
    // delegator=>vault=>total amount borrowed
    mapping(address=>mapping(string=>uint)) public totalBorrowed;

    // mapping to find to who the owner has delegated and how much
    // delegator=>borrower=>vault=>amount delegated  
    mapping(address=>mapping(address=>mapping(string=>uint))) public hasDelegated; 

    // mapping to know the total of tokens that have been delegated by each delegator
    // delegator=>vault=>total amount delegated
    mapping(address=>mapping(string=>uint256)) totalDelegated;

    //keep track of the orignil owner adress of the nft vault
    // original_owner => vault name => nft_id
    mapping(address=>mapping(string=>uint256[])) public isOwner;

    // vault name (WETH, WBTC, ...) mapped with the address of the associated mai-finance vault contract
    mapping(string => address) vaultAddress;

    // token name (WETH, WBTC, ...) mapped with the address of their contract
    mapping(string => address) tokenAddress;

    // ERC721 deposit 
    // VERIFIER QUE _VAULT CORRESPOND BIEN AU VAULT DU NFT 
    function erc721_deposit(string memory _vault, uint256 _erc721_Id, uint256 _maxAmountToBorrow) public{ 
        // ATTENTION vérifier si le erc 721 est bien défini comme un nft de mai finance => normalement c'est ok : on require auprès du vault que le owner du nft est bien notre contract
        // check that the msg sender is the owner of the nft
        require(vaultAddress[_vault].ownerOf(_erc721_Id)==msg.sender, "You must be the owner of the token");
        // call safeTransferFrom in the vault contract
        vaultAddress[_vault].safeTransferFrom(msg.sender, address(this), _erc721_Id); // APPELER LA FCT AU NOM DU MSG.SENDER 
        // check if our contract received the nft
        require(vaultAddress[_vault].ownerOf(_erc721_Id)==address(this), "the ERC721 is not in our contract");
        // add the nft to the mapping isOwner
        isOwner[msg.sender][_vault].push(_erc721_Id);
        // try to borrow the max amount to borrow
        uint256 initialBalance = vaultAddress[_vault].balanceOf(address(this));
        // comment vérifier le montant max à emprunter ?
        // borrow the amount from Qidao
        uint256 _front = 0;
        vaultAddress[_vault].borrowToken(_erc721_Id, _maxAmountToBorrow, _front);
        // check the amount of _vault in our contract
        uint256 finalBalance = vaultAddress[_vault].balanceOf(address(this));
        // check that the amount borrowed is equal or superior to the amount of _vault in our contract
        require(finalBalance-initialBalance>=_maxAmountToBorrow, "The amount borrowed hasn't been received");
        // mappping to keep track of the amount borrowed by msg.sender
        borrowedAmount[msg.sender][_vault] += _maxAmountToBorrow;
        // emit event
        emit BorrowedToMaiFinance(msg.sender, vaultAddress[_vault], _maxAmountToBorrow);
    }

    // ERC721 withdraw
    // a priori, fees déduites automatiquement par mai finance
    function erc721_withdraw(string memory _vault, uint256 _erc721_Id) public{
        // check that the nft is in our contract
        require(vaultAddress[_vault].ownerOf(_erc721_Id)==address(this), "The ERC721 is not owned by our contract");
        // check that the msg sender is the owner of the nft
        bool _isOwner = false;
        for (uint i = 0; i < isOwner[msg.sender][_vault].length - 1; i++) {
            if(isOwner[msg.sender][_vault][i] == _erc721_Id) {_isOwner = true; break;}            
        }
        require(_isOwner, "You must be the owner of the token");
        // check if some tokens have been delegated
        require(borrowedAmount[msg.sender][_vault] - totalDelegated[msg.sender] >= 0, "You cannot withdraw this token, you need to reduce the amount you have delegated first");
        // our contract repay the amount to the vault
        uint256 _front = 0;
        // ATTENTION, CA NE DEVRAIT MARCHER QUE SI L'UTILISATEUR N'A DEPOSE QUE 1 NFT PAR TYPE DE VAULT. SI ON VEUT FAIRE POUR TOUS LES CAS, IL FAUT CHANGER LE CALCUL DE AMOUNT
        uint256 value_borrowed_in_this_vault = borrowedAmount[msg.sender][_vault] - totalDelegated[msg.sender]; // pas sur de ca
        vaultAddress[_vault].payBackToken(vaultID, value_borrowed_in_this_vault, _front);
        // update user's dept
        borrowedAmount[msg.sender][_vault] -= value_borrowed_in_this_vault;
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

    function approveDelegation(address _borrower, uint _amount, string memory _vault) public {
        
        // security check
        require(delegationCapacity(msg.sender, _vault)-_amount>=0, "the amount delegated is superior to the amount authorized");
        require(_borrower!=address(0), "borrower can't be address(0)");
        require(_borrower!=msg.sender, "borrower must be different that owner");
        require(_amount>0, "amount borrowed must be superior to 0");
        require(vaultAddress[_vault], "the vault doesn't exist"); // demander à nandy si ca marche 
        require(_amount-borrowed[msg.sender][_borrower][_vault]>=0, "The borrower has already borrowed more than the new authorized amount");
        // update the mapping with the amount authorized 
        if(hasDelegated[msg.sender][_borrower][_vault] <= _amount){
            totalDelegated[msg.sender][_vault] += (_amount-hasDelegated[msg.sender][_borrower][_vault]);
        }
        else{
            totalDelegated[msg.sender][_vault] += (hasDelegated[msg.sender][_borrower][_vault]-_amount);
        }
        hasDelegated[msg.sender][_borrower][_vault] = _amount;       

        emit Approved(msg.sender, _borrower, _amount, vaultAddress[_vault]);

    }

    // function to call for the borrower to get the fund 
    function borrow(uint _amount, address _delegator, string memory _vault) public {
        //check that the amount borrow is not superior to the amount delegated 
        require(_amount!=0, "Can't borrow 0 token"); 
        require(_amount<= hasDelegated[_delegator][msg.sender][_vault]-borrowed[_delegator][msg.sender][_vault], "Borrow an amount superior to the amount delegated");

        //call the fonction on the mini matic contract to send the 
        maiEth.transferFrom(address(this),msg.sender,_amount); 
        //+= to prevent someone calling the contract with a small amount to change his debt 
        borrowed[_delegator][msg.sender][_vault] += _amount; 
        totalBorrowed[_delegator][_vault] += _amount;
        require(borrowed[_delegator][msg.sender][_vault]-totalBorrowed[_delegator][_vault]>=0, "Je ne sais pas quoi mettre comme erreur");
        emit Borrowed(_amount, _delegator, vaultAddress[_vault]);
    }    

    // function to allow the borrower to repay his debt 
    function repayToOurContract(uint _amount, address _delegator, string memory _vault) public {
        require(_amount!=0, "Can't repay 0 token"); 
        //check that the amount borrow is not superior to the amount delegated 
        require(_amount <= borrowed[_delegator][msg.sender][_vault], "Repay an amount superior to the amount borrowed");
        // check that the borrower has enough token to repay
        require(maiEth.balanceOf(msg.sender)>=_amount, "You don't have enough Mai to repay this amount");
        // check the vault exist
        require(vaultAddress[_vault], "the vault doesn't exist"); 
        // Save the amount of Mai in our contract
        uint256 _initialAmount = maiEth.balanceOf(address(this));
        // Call the fonction on the mini matic contract to send the 
        maiEth.transferFrom(msg.sender,address(this),_amount); // REQUIRE UN APPROVE AVANT NON ?
        uint256 _finalAmount = maiEth.balanceOf(address(this));
        require(_finalAmount - _initialAmount >= _amount, "The amount of Mai sent is not the same as the amount of Mai received");
        // Edit the mapping borrowedAmount
        borrowed[_delegator][msg.sender][_vault] -= _amount; 
        totalBorrowed[_delegator] -= _amount;
        emit RepaidToOurContract(_amount, _delegator, vaultAddress[_vault]);
    }



    // // repay to mai finance to deposit collateral => DOIT RENVOYER SUR MAI FINANCE LES TOKENS DE MSG.SENDER, PAS CEUX DU CONTRACT
    // // ATTENTION, COMMENT ON GERE LES TOKENS QUI ON ETE EMPRUNTES PAR NOTRE CONTRAT MAIS REMBOURSES PAR QUELQU'UN ?
    // function addCollateralToMaiFinance(uint _amount, uint _tokenid, string memory _vault) public{
    //     vaultAddress[_vault].depositCollateral(_tokenid,_amount); 
    //     emit PayToMayFinance(_amount, _tokenid, vaultAddress[_vault],false);
    // }

    // allow the owner of the _tokenId to add collateral to mai finance from the amount borrowed by our contract
    function addCollateralToMaiFinanceFromOurContract(uint _amount, uint _tokenid, string memory _vault) public {
        // check if msg.sender is the owner of _tokenid      
        require(isOwnedBy(_tokenid), "You are not the owner of this token");
        // correspond to the vault of the token
        require(vaultAddress[_vault], "the vault doesn't exist");
        // check if the amount is not superior to the available amount 
        require(_amount<=totalDelegated[msg.sender][_vault]-totalBorrowed[msg.sender][_vault] , "The amount is superior to the amount borrowed");
        // check if the amount is not superior to the amount borrowed by our contract
        require(_amount<=borrowedAmount[msg.sender][_vault], "The amount is superior to the amount borrowed by our contract");

        // call the function on the vault contract to deposit the collateral
        vaultAddress[_vault].depositCollateral(_tokenid,_amount);
        // edit the mapping borrowedAmount
        borrowedAmount[msg.sender][_vault] -= _amount;
        emit PayToMayFinance(_amount, _tokenid, vaultAddress[_vault],true);
    }

    // admin functions

    function addAdmin(address _admin) public {
        require(admin[msg.sender], "You are not an admin");
        admin[_admin] = true;
    }

    // edit the address of the qi DAO vault contract associated with _tokenName
    function edit_vaultAdress(string memory _tokenName, address _vault) public {
        require(admin[msg.sender], "You are not an admin");
        vaultAddress[_tokenName] = _vault;
    }


    // view functions
    function getDepositedValue(address _delegator, string memory _token) public view {
        require(tokenAddress[_token] != 0x0000000000000000000000000000000000000000, "Unknown token");
        return borrowedAmount[_delegator][_token];
    }

        function isAdmin(address _admin) public view returns(bool) {
        return admin[_admin];
    }


    // view function to get the token id of an address
    // user=> adress that we want to see
    //_vault=> name of the vault (WETH, WBTC)
    function getTokenIdByVault(address user, string calldata _vault) external view{
        return isOwner[user][_vault]; 
    }

    // view function to get the amount of token borrowed by an address
    function getBorrowedAmount(address _borrower, address _delegator, string calldata _vault) external view{
        return hasDelegated[_delegator][_borrower][_vault]; 
    }

    // view function to know how many token an address can borrow from a delegator
    function getMaxBorrowingAmount(address _borrower, address _delegator, string calldata _vault) external view{
        return borrowed[_delegator][_borrower][_vault]; 
    }

    // how many token can I borrow with 1 delegator
    function borrowableAmount(address _borrower, address _delegator, string calldata _vault) external view{
        return hasDelegated[_delegator][_borrower][_vault] - borrowed[_delegator][_borrower][_vault]; 
    }

    // how many token can I delegate
    function maxDelegationCapacity(address _delegator, string memory _vault) public view returns(uint256){
        return borrowedAmount[_delegator][_vault];
    }

    // how many token that can be delegated
    function delegationCapacity(address _delegator, string memory _vault) public view returns(uint256){
        return borrowedAmount[_delegator][_vault] - totalBorrowed[_delegator][_vault];
    }

    function getVaultAddress(string memory _vault) public view returns(address){
        return vaultAddress[_vault];
    }

    // get the total borrowed amount of a delegator
    function getBorrowedAmount(address _delegator, string memory _vault) public view returns(uint256){
        return totalBorrowed[_delegator][_vault];
    }

    // get the total of tokens that have been borrowed from _delegator
    function getTotalBorrowed(address _delegator) public view returns(uint256){
        return totalBorrowed[_delegator];
    }

    // is an address the owner of _tokenId ?
    function isOwnedBy(uint256 _tokenId, string memory _vault) public view{
        bool owner = false;
        for (uint i = 0; i < isOwner[msg.sender][_vault].length - 1; i++) {
            if(isOwner[msg.sender][_vault][i] == _tokenId){
                owner = true;
                break;
            }
        }
        return owner;
    }

    // faire une fonction qui te donne toutes les addresses auprès desquelles on a des créances ?
    // Permettre d'emprunter au nom de 1 delegateur à la fois ou est ce qu'e si tom et lea me prettent chacun 10 BTC je peux faire 1 seul emprunt de 20 BTC ?
}
