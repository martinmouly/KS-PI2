import './App.css';
import { ethers } from 'ethers';
import aaveLogo from'./img/aave-cd.png';
import LendingPoolABI from './ABIs/lendingPool.json';
import varDebtUSDCABI from './ABIs/varDebtUSDC.json';
import usdc from './img/usdc.png'
import { useState } from 'react';

function Deleg() {

    const [delegatee, setDelegatee] = useState(null);
    const [amount, setAmount] = useState(null);


    function handleSubmit(event) {
        event.preventDefault();
        delegation()
    }
    

    function delegation() {
        
        const variableDebtContract = "0xcfc2d9b9498cBd6F71E5E46d46082C76C4F6C695"
        const contractAbi = varDebtUSDCABI
        const decimals = 6

        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
    
        const contract = new ethers.Contract(variableDebtContract, contractAbi, signer);
        const callFunction = contract.approveDelegation(delegatee, amount*(10**decimals));
      }

    return(
        <div className="App">
            <div className='App-header'>
             <img src={aaveLogo}></img>
            </div>
            <form className='form-box' onSubmit={handleSubmit}>
                <input placeholder="Delegatee address" value={delegatee} onChange={event => setDelegatee(event.target.value)}/>
                <input placeholder="Amount" value={amount} onChange={event => setAmount(event.target.value)}/><br></br>
                <button className='button-4'>Delegate
                <img src={usdc} width={20} height={20} className="usdc"></img>USDC </button>
            </form>
                
        </div>
    );
}

export default Deleg