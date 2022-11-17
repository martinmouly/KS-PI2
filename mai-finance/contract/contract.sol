pragma solidity ^0.8.13; // regarder la version sur les contracts de qidao

contract delegate {


    event Authorized(address indexed owner, address indexed borrower, uint amount); 

    // structure d'une délégation 
    struct Delegate {
        address _owner; 
        address _borrower; 
        uint _amount; 
        bool _authorized; 
    }

    // mapping pour retrouver la combien l'owner à déléguer au borrower 
    mapping(address=> mapping(address=>uint)) public hasdelegated; 

    // regarder s'il faut le définir en internal
    Delegate [] public delegate_array; 

    // fonction pour approuver la délagation
    // voir comment remplacer les owner par msg.sender sur remix 
    function approveDelegation(address _owner, address _borrower, uint _amount) public {
        require(_borrower!=_owner && _amount>0);
        delegate_array.push(Delegate(_owner, _borrower, _amount, true)); 
        hasdelegated[_owner][_borrower] = _amount; 
        emit Authorized(_owner, _borrower, _amount); 
    }

}