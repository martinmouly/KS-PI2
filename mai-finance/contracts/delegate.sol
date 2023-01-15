pragma solidity ^0.8.4; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract delegate{

    address nftVaultAddress; 

    address maiToken = address(0xd9145CCE52D386f254917e481eB44e9943F39138); 

    mapping(address=>mapping(string=>uint256[])) public isOwner; // mapping à la place du uint256

    mapping(address=>mapping(address=>mapping(string=>uint))) public hasDelegated; 

    mapping(string => address) public vaultAddress;

    mapping(address=>mapping(string=>uint)) public borrowedAmount;


    event TokenReceived(address, uint256); 

    event DelegationApproved(address, address, string, uint256, uint256); 

    event BorrowedToMaiFinance(address indexed depositor, address vault, uint256 amount);




    ERC20 public mai; 
    

    constructor(address _mai) {
         
        vaultAddress["tempo"] = address(0x406AB5033423Dcb6391Ac9eEEad73294FA82Cfbc);
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
        hasDelegated[_owner][_borrower][_vault] = _amount; 

        // the delegation is approved so the contract borrow amount to my finance 
        (bool success,) = vaultAddress[_vault].call(abi.encodeWithSignature("borrowToken(uint256,uint256,uint256)",_erc721_Id,_amount,0)); 
        if(success!=true)
            revert("Error while borrowing Token to Mai Finance");  
        emit BorrowedToMaiFinance(_owner, vaultAddress[_vault], _amount); 
    }


    function userBorrowMai(uint256 _amount, address _owner, address _borrower, string memory _vault) public{
        if(msg.sender != _borrower)
            revert("You must be the borrower"); 
        if(_amount>hasDelegated[_owner][_borrower][_vault])
            revert("you can't borrow more than the amount athorized");
        mai.transfer(msg.sender,_amount); 

    }

    function erc721_withdraw_requirement(string memory _vault, uint256 _erc721_Id) internal returns (bool) {
        // check that the nft is in our contract
        address owner = IERC721(vaultAddress[_vault]).ownerOf(_erc721_Id); 
        if(owner!=address(this))
            revert("This token is not owned by the contract"); 
        // check that the msg sender is the owner of the nft
        bool _isOwner = false;
        for (uint i = 0; i < isOwner[msg.sender][_vault].length - 1; i++) {
            if(isOwner[msg.sender][_vault][i] == _erc721_Id) {
                _isOwner = true; 
                break;}            
        }
        if(_isOwner!=true)
            revert("You must be the depositor of this NFT to withdraw it");
        return(true); 
    }
}