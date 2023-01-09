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
    

    async function delegation() {
        
        const variableDebtContract = "0xcfc2d9b9498cBd6F71E5E46d46082C76C4F6C695"
        const contractAbi = varDebtUSDCABI

        const provider = await new ethers.providers.Web3Provider(window.ethereum);
        const signer = await provider.getSigner();
    
        const contract = await new ethers.Contract(variableDebtContract, contractAbi, signer);
        const callFunction = await contract.approveDelegation(delegatee, amount);
      }

    return(
        <div className="App">
            <div className='App-header'>
             <img src={aaveLogo}></img>
            </div>
            <form className='form-box'>
                <input placeholder="Delegatee address"/>
                <input placeholder="Amount"/><br></br>
            </form>
                <button onClick={delegation} className='button-4'>Delegate
                <img src={usdc} width={20} height={20} className="usdc"></img>USDC </button>
        </div>
    );
}

export default Deleg