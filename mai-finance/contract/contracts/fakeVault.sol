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

    mapping (uint256 => address) public owners; // associe un nft a son owner
    mapping (address => uint256) public erc721Balance; // balance de nft d'un owner
    mapping(uint256 => uint256) public _deposit; // deposit dans le vault : vault => montant total déposé
    mapping(uint256 => uint256) public maiDebt; // montant de mai emprunté par une vault : vault => debt
    mapping(address => uint256) public maiBalance; // monta de may détenu par chaque addresse

    uint256 vaultCount = 0;

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

    function Transfer(address _to, uint256 _erc721_Id) public {
        require(owners[_erc721_Id] == msg.sender, "You are not the owner of this NFT");
        owners[_erc721_Id] = _to;
        erc721Balance[msg.sender] -= 1;
        erc721Balance[_to] += 1;
    }

    function TransferFrom(address from, address to, uint256 amount) public {
        require(owners[_erc721_Id] == msg.sender, "You are not the owner of this NFT");
        owners[_erc721_Id] = _to;
        erc721Balance[from] -= 1;
        erc721Balance[_to] += 1;
    }

    function TransferMai(address _to, uint256 amount) public {
        require(maiBalance[msg.sender] >= amount, "You don't have enough mai");
        maiBalance[msg.sender] -= amount;
        maiBalance[_to] += amount;
    }

    function TransferMaiFrom(address from, address to, uint256 amount) public {
        require(maiBalance[from] >= amount, "You don't have enough mai");
        maiBalance[from] -= amount;
        maiBalance[_to] += amount;
    }

    function updateVaultDebt(uint256 vaultId) public view returns (uint256) {
        return maiDebt[vaultId];
    }

    function payBackToken( uint256 vaultID, uint256 amount, uint256 _front) public {
        require(owners[vaultID] == msg.sender, "You are not the owner of this vault");
        require(maiDebt[vaultID] >= amount, "You don't have enough debt");
        require(maiBalance[msg.sender] >= amount, "You don't have enough mai");
        maiDebt[vaultID] -= amount;
        maiBalance[msg.sender] -= amount;
    }

    function depositCollateral(uint256 vaultID, uint256 amount) public {
        require(owners[vaultID] == msg.sender, "You are not the owner of this vault");
        _deposit[vaultID] += amount;
    }

    function withdrawCollateral(uint256 vaultID, uint256 amount) public {
        require(owners[vaultID] == msg.sender, "You are not the owner of this vault");
        require(_deposit[vaultID] >= amount, "You don't have enough collateral");
        require(maiDebt[vaultID] * (1/0.8) <= _deposit[vaultID] - amount, "You don't have enough collateral");
        _deposit[vaultID] -= amount;
        maiBalance[msg.sender] += amount;
    }

    function newVault() public{
        vaultCount += 1;
        owners[vaultCount] = msg.sender;
        erc721Balance[msg.sender] += 1;
    }


    // view
    function getMaiBalance(address _owner) public view returns (uint256) {
        return maiBalance[_owner];
    }
    function getVaultDebt(uint256 _vaultId) public view returns (uint256) {
        return maiDebt[_vaultId];
    }
    function getVaultCollateral(uint256 _vaultId) public view returns (uint256) {
        return _deposit[_vaultId];
    }
    function getOwner(uint256 _vaultId) public view returns (address) {
        return owners[_vaultId];
    }

    //faucet
    function getMai(uint256 _amount) public {
        maiBalance[msg.sender] += _amount;
    }


    
}
