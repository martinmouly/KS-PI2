// min des fcts a faire :
// ownerOf
// balanceOf
// borrowToken
// depositCollateral
// Transfer
// updateVaultDebt
// payBackToken
// depositCollateral

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract fakeMaiVault{

    mapping (address => bool) public admin; // nous
    mapping (uint256 => address) public owners; // associe un nft a son owner
    mapping (address => uint256) public erc721Balance; // balance de nft d'un owner
    mapping(uint256 => uint256) public _deposit; // deposit dans le vault : vault => montant total déposé
    mapping(uint256 => uint256) public maiDebt; // montant de mai emprunté par une vault : vault => debt

    constructor(){
        admin[msg.sender] = true;
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return owners[_tokenId];
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return erc721Balance[_owner];
    }

    function borrowToken(uint256 _erc721_Id,uint256 amount,uint256 _front) public {
        require(owners[_erc721_Id] == msg.sender, "You are not the owner of this NFT");
        require(_deposit[_erc721_Id] - maiDebt * 0.8 >= amount, "You don't have enough collateral");
        maiDebt[_erc721_Id] += amount;
        // transfert de token
    }

    function depositCollateral(uint256 _erc721_Id,uint256 amount) public {
        require(owners[_erc721_Id] == msg.sender, "You are not the owner of this NFT");
        _deposit[_erc721_Id] += amount;
    }

    
}
