import './App.css';
import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import aaveLogo from'./img/aave-cd.png';
import mmFox from'./img/MetaMask_Fox.png';
import { useNavigate } from 'react-router-dom';
import usdc from './img/usdc.png'
import { Link } from 'react-router-dom';

function Home() {

  
  const [currentAccount, setCurrentAccount] = useState(null);
  const navigate = useNavigate();

  const connectWalletHandler = async () => {
    const { ethereum } = window

      const accounts = await ethereum.request({method:'eth_requestAccounts'})
      setCurrentAccount(accounts[0])
  }

  const connectWalletButton = () => {
    return (
      <div className='mm-button'>
        <button onClick={connectWalletHandler} className='button-4'>
        <img src={mmFox} width={20} height={20}></img>
        Connect Wallet
        </button>
      </div>
        
    );
  }

  const goToDeleg = () => {
    navigate("/delegate");
  }

  const goToBorrow = () => {
    navigate('/borrow')
  }

  const handleClick = () => {
    return(
    <div className="App">
      <p>Connected to : {currentAccount}</p>
      <p>I want to </p>
      <div className="delegate-or-borrow">
      <button onClick={goToDeleg} className='button-4'>Delegate
      <img src={usdc} width={20} height={20} className="usdc"></img>USDC</button>
        <div className="borrow-btn">
            <button onClick={goToBorrow} className='button-4'>Borrow
            <img src={usdc} width={20} height={20} className="usdc"></img>USDC </button>
        </div>
      </div>
    </div>
    )
  }

  return (
    <div className="App">
      <div className='App-header'>
        <Link to="/">
          <img src={aaveLogo}></img>
        </Link>
      </div>
        {(currentAccount) ? handleClick() : connectWalletButton()}
    </div>
  );
}

export default Home;
