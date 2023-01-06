import logo from './logo.svg';
import './App.css';
import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import LendingPoolABI from './ABIs/lendingPool.json';
import varDebtUSDCABI from './ABIs/varDebtUSDC.json'

function App() {

  const [currentAccount, setCurrentAccount] = useState(null);

  const connectWalletHandler = async () => {
    const { ethereum } = window

      const accounts = await ethereum.request({method:'eth_requestAccounts'})
      setCurrentAccount(accounts[0])
  }

  const connectWalletButton = () => {
    return (
      <button onClick={connectWalletHandler} className='App-mm-button'>
        Connect Wallet
      </button>
    );
  }

  const delegation = async () => {
    const delegatee = "0xcfc2d9b9498cBd6F71E5E46d46082C76C4F6C695"
    const amount = 10000000000000
    const variableDebtContract = "0xcfc2d9b9498cBd6F71E5E46d46082C76C4F6C695"
    const contractAbi = varDebtUSDCABI
    const provider = await new ethers.providers.Web3Provider(window.ethereum);
    const signer = await provider.getSigner();

    const contract = await new ethers.Contract(variableDebtContract, contractAbi, signer);
    const callFunction = await contract.approveDelegation(delegatee, amount);
  }

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

  const handleClick = () => {
    return(
    <div className="App">
      <p>{currentAccount}</p>
      <button onClick={delegation}>Delegate USDC</button><p></p>
      <button onClick={borrow}>Borrow USDC</button>
    </div>
    )
  }

  return (
    <div className="App">
        {(currentAccount) ? handleClick() : connectWalletButton()}
    </div>
  );
}

export default App;
