pragma solidity ^0.8.4; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "hardhat/console.sol"; 
import "./FakeVault.sol"; 

contract delegate{

    address nftVaultAddress; 


    mapping(address=>mapping(string=>uint256[])) public isOwner; // mapping à la place du uint256

    // owner => borrower => vaultName => tokenId => amount delegated 
    mapping(address=>mapping(address=>mapping(string=>mapping(uint256=>uint256)))) public hasDelegated; 

    mapping(address=>mapping(address=>mapping(string=>mapping(uint256=>uint256)))) public hasBorrowed; 


    mapping(string => address) public vaultAddress;


    mapping(string => mapping(uint256 => uint256)) public vaultDebt ; 


    event TokenReceived(address, uint256); 

    event DelegationApproved(address, address, string, uint256, uint256); 

    event BorrowedToMaiFinance(address indexed depositor, address vault, uint256 amount);

    event NftWithdrawn(address, string, uint256); 

    ERC20 public mai;
    FakeVault public _fakevault; 


    constructor(address _mai, address _vault) {
         
        vaultAddress["tempo"] = address(_vault);
        mai = ERC20(_mai); 
    }
 
    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public returns (bytes4) {
            return this.onERC721Received.selector;
    }
    
    // Depositor need to approve the address of the contract by calling approve to deposit ERC721
    function depositErc721(uint256 _erc721_Id, string memory _vault) public {

        address owner = IERC721(vaultAddress[_vault]).ownerOf(_erc721_Id); 
        if(owner!=msg.sender)
            revert("you are not the owner of the vault"); 

        IERC721(vaultAddress[_vault]).safeTransferFrom(owner, address(this),_erc721_Id); 
      
        address newOwner = IERC721(vaultAddress[_vault]).ownerOf(_erc721_Id);
        if(newOwner!=address(this))
            revert("Error nft not received");  
        isOwner[msg.sender][_vault].push(_erc721_Id);

        emit TokenReceived(msg.sender, _erc721_Id); 
    }

    // for mai finance, the contract borrow, so It keep rtack of the contrcat address
    function approveDelegation(address _owner, address _borrower, string memory _vault, uint256 _erc721_Id, uint256 _amount) public{
        bool ownVault = false; 

        if(msg.sender!=_owner)
            revert("You must be the owner of the vault"); 
        if(_amount<=0)
            revert("You must delegate more than 0"); 
        if(_borrower==_owner)
            revert("You can't delegate to the same address"); 
        if(_borrower==address(0))
            revert("You can't delegate to adress(0) (0x0000000000000)"); 
        for (uint i=0; i <= isOwner[_owner][_vault].length -1; i++) {
            
            if (_erc721_Id == isOwner[_owner][_vault][i]) {
                ownVault = true;
                break;
            }
        }
        if(ownVault==false)
            revert("You must own the vault to delegate");    
        hasDelegated[_owner][_borrower][_vault][_erc721_Id] = _amount; 

        // the delegation is approved so the contract borrow amount to my finance 
        /*(bool success,) = vaultAddress[_vault].call(abi.encodeWithSignature("borrowToken(uint256,uint256,uint256)",_erc721_Id,_amount,0)); 
        if(success!=true)
            revert("Error while borrowing Token to Mai Finance");  */
        emit BorrowedToMaiFinance(_owner, vaultAddress[_vault], _amount); 
    }

    
    function userBorrowMai(address _owner, address _borrower, string memory _vault, uint256 _erc721_Id) public{
        if(msg.sender != _borrower)
            revert("You must be the borrower"); 
        uint _amount = hasDelegated[_owner][_borrower][_vault][_erc721_Id]; 
        console.log(_amount); 
        (bool success,) = vaultAddress[_vault].call(abi.encodeWithSignature("borrowToken(uint256,uint256,uint256)",_erc721_Id,_amount,0)); 
         if(success!=true)
            revert("Error while borrowing Token to Mai Finance");  
        mai.transfer(msg.sender,_amount); 
        hasBorrowed[_owner][_borrower][_vault][_erc721_Id] = _amount; 
        vaultDebt[_vault][_erc721_Id] = _amount; 
    }


    // the _borrower must add allowance to the contract
    // PROBLEME EN APPEANT PAYBACK CAR PAS D ALLOWANCE POUR LE SAFETRANSFER 
    function repayLoan(uint256 _amount, address _owner, address _borrower, string memory _vault, uint256 _erc721_Id) public {
        FakeVault _fake = FakeVault(vaultAddress[_vault]); 
        if(_amount!=hasBorrowed[_owner][_borrower][_vault][_erc721_Id])
            revert("You must repay the amount of the loan"); 
            
        mai.increaseAllowance(vaultAddress[_vault], _amount); 
        
        mai.transferFrom(msg.sender, address(this), _amount); 
        _fake.payBackToken(_erc721_Id, _amount, 0); 
        
    }   

    // voir comment le contrat fait quand le borrower n'a pas emprunter 
    function withdraw_NFT(string memory _vault, uint256 _erc721_Id, address _owner, address _borrower) public {
        if(vaultDebt[_vault][_erc721_Id] != 0)
            revert("The loan must be repay before withrawing the nft"); 
        bool owner = false; 
         for (uint i = 0; i < isOwner[msg.sender][_vault].length - 1; i++) {
            if(isOwner[msg.sender][_vault][i] == _erc721_Id) {
                owner = true; 
                break;
            }            
        }
        IERC721(vaultAddress[_vault]).safeTransferFrom(address(this), msg.sender, _erc721_Id); 
        emit NftWithdrawn(msg.sender, _vault,_erc721_Id); 
    }

    function testAllowance( string memory _vault) public {
        mai.increaseAllowance(vaultAddress[_vault],400); 
    }
}