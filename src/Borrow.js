import './App.css';
import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import aaveLogo from'./img/aave-cd.png';
import mmFox from'./img/MetaMask_Fox.png';
import { useHistory } from "react-router-dom";
import LendingPoolABI from './ABIs/lendingPool.json';
import varDebtUSDCABI from './ABIs/varDebtUSDC.json';
import usdc from './img/usdc.png'

function Borrow() {

    const [delegator, setDelegator] = useState(null);
    const [amount, setAmount] = useState(null);

    function handleSubmit(event) {
        event.preventDefault();
        borrowLogic()
    }

    function borrowLogic() {
        const contractAbi = LendingPoolABI
        const poolContract = "0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210"
        const asset = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074"
        const decimals = 6

        const provider =  new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();

    
        const contract = new ethers.Contract(poolContract, contractAbi, signer);
        const callFunction = contract.borrow(asset,amount*(10**decimals),2,0,delegator);
  }

    return(
        <div className="App">
            <div className='App-header'>
             <img src={aaveLogo}></img>
            </div>
            <form className='form-box' onSubmit={handleSubmit}>
                <input placeholder="Delegator address" value={delegator} onChange={event => setDelegator(event.target.value)}/>
                <input placeholder="Amount" value={amount} onChange={event => setAmount(event.target.value)}/><br></br>
                <button className='button-4'>Borrow
                <img src={usdc} width={20} height={20} className="usdc"></img>USDC </button>
            </form>
                
        </div>
    );
}

export default Borrow