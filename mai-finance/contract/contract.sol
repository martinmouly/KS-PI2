// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface PriceSource {
	function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract delegate {


    event Authorized(address indexed owner, address indexed borrower, uint amount); 

    // struct to represent a delegation
    struct Delegate {
        address _owner; 
        address _borrower; 
        uint _amount; 
        bool _authorized; 
    }

    // mapping to find to who the owner has delegated and how much  
    mapping(address=> mapping(address=>uint)) public hasDelegated; 

    // regarder s'il faut le définir en internal
    Delegate [] public delegate_array; 

    // fonction pour approuver la délagation
    // voir comment remplacer les owner par msg.sender sur remix 
    function approveDelegation(address _owner, address _borrower, uint _amount) public {

        // we check that the msg sender is the owner of the fund 
        require(_owner==msg.sender, "this address is not the owner of the funds");
        require(_borrower!=address(0), "borrower can't be address(0)");
        require(_borrower!=_owner, "borrower must be different that owner");
        require (_amount>0, "amount borrowed must be superior to 0");
        // need to add the require to check that the owner has deposit collateral and don't use it 

        delegate_array.push(Delegate(_owner, _borrower, _amount, true)); 
        hasDelegated[_owner][_borrower] = _amount; 
        emit Authorized(_owner, _borrower, _amount); 
    }




    mapping(address=>uint256[]) public isDepositor;

    // nft deposit
    function erc721_deposit(address minter, uint256 erc721_Id) public{
        // call safeTransferFrom
        IERC721(minter).safeTransferFrom(msg.sender, address(this), erc721_Id);
        // add the nft to the mapping isDepositor
        isDepositor[msg.sender].push(erc721_Id);
    }



    // emprunter 

    mapping(address=> mapping(address=>uint)) public amountBorrowed; 


    function borrow(uint _amount, address initialBorrower, address vaultAddress) public {
        // check that the amount borrowed is superior to 0
        require(_amount>0, "amount borrowed must be superior to 0");
        // check that the initial borrower has delegated to the msg.sender
        require(hasDelegated[initialBorrower][msg.sender]>0, "this borrower has not delegated to you"); // borrow from himself
        // check that the amount already borrowed + new borrow is inferior to the maximal amount delegated
        require(_amount + amountBorrowed[msg.sender][_initialBorrower]<=hasDelegated[initialBorrower][msg.sender], "the amount borrowed is superior to the amount delegated");
        
        
        // borrow the amount from Qidao
        vaultAddress.call.gas(1000000).value(1 ether)("foo(string,uint256)", "argument 1", "argument2"); // foo = fct du contrat vault à appeler Quelle value ?
        // add the amount borrowed to the mapping amountBorrowed
        amountBorrowed[msg.sender][_initialBorrower] += _amount;

    }            
    

}

