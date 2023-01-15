pragma solidity ^0.8.4; // regarder la version sur les contracts de qidao 0.5.5 demander à Nandy quel est le mieux 

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



pragma solidity ^0.8.0;


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract VaultNFTv4 is ERC721 {

    string public uri;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol){}
    

  
    
}

contract fakeMaiVault is VaultNFTv4{
        using SafeERC20 for ERC20;
        ERC20 public mai;



    mapping (uint256 => address) public owners; // associe un nft a son owner
    mapping (address => uint256) public erc721Balance; // balance de nft d'un owner
    mapping(uint256 => uint256) public _deposit; // deposit dans le vault : vault => montant total déposé
    mapping(uint256 => uint256) public maiDebt; // montant de mai emprunté par une vault : vault => debt
    mapping(address => uint256) public maiBalance; // monta de may détenu par chaque addresse

    uint256 vaultCount = 0;
    address _mai = address(0xd9145CCE52D386f254917e481eB44e9943F39138); 

    constructor(string memory name, string memory symbol)VaultNFTv4(name, symbol){
        mai = ERC20(_mai); 
    }


    function createVault() public returns (uint256) {
        uint256 id = vaultCount;
        vaultCount = vaultCount + 1;
        require(vaultCount >= id);
        _mint(msg.sender, id);
        return id;
    }


    function borrowToken(uint256 _erc721_Id,uint256 _amount,uint256 _front) public  {
        require(ownerOf(_erc721_Id) == msg.sender, "You are not the owner of this NFT");
        require(_deposit[_erc721_Id] - maiDebt[_erc721_Id] >= _amount, "You don't have enough collateral");
        mai.safeTransfer( msg.sender, _amount);
        // transfert de token
    }

    function depositCollateral(uint256 _erc721_Id,uint256 amount) public {
        require(ownerOf(_erc721_Id) == msg.sender, "You are not the owner of this NFT");
        _deposit[_erc721_Id] += amount;
    }


    function TransferFrom(address from, address _to, uint256 _erc721_Id) public {
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

    function TransferMaiFrom(address from, address _to, uint256 amount) public {
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

    function withdrawCollateral(uint256 vaultID, uint256 amount) public {
        require(owners[vaultID] == msg.sender, "You are not the owner of this vault");
        require(_deposit[vaultID] >= amount, "You don't have enough collateral");
        require(maiDebt[vaultID] <= _deposit[vaultID] - amount, "You don't have enough collateral");
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
        return IERC20(mai).balanceOf(_owner);
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