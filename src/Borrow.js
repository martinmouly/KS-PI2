import './App.css';
import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import aaveLogo from'./img/aave-cd.png';
import mmFox from'./img/MetaMask_Fox.png';
import { useHistory } from "react-router-dom";
import LendingPoolABI from './ABIs/lendingPool.json';
import varDebtUSDCABI from './ABIs/varDebtUSDC.json';

function Borrow() {

    const borrow = async () => {
    const provider = await new ethers.providers.Web3Provider(window.ethereum);
    const signer =await provider.getSigner();
    const contractAbi = LendingPoolABI
    const poolContract = "0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210"

    const asset = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074"
    const onBehalfOf= "0xc22F7bF6c1c7Ed5220eb7Be4F0Cd8a69e9fBa0F9"
    const amount = 100

    const contract = await new ethers.Contract(poolContract, contractAbi, signer);
    const callFunction =await contract.borrow(asset,amount,2,0,onBehalfOf);
  }

    return(
        <div className="App">
            <div className='App-header'>
             <img src={aaveLogo}></img>
            </div>
            <form className='form-box'>
                <input placeholder="Delegator address"/>        
                <input placeholder="Amount"/><br></br>
            </form>
            <button onClick={borrow} className='button-4'>Borrow USDC</button>
 
        </div>
    );
}

export default Borrow