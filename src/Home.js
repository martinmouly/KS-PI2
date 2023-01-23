import "./App.css";
import { ethers } from "ethers";
import { useEffect, useState } from "react";
import usdcABI from "./ABIs/usdc.json";
import ausdcABI from "./ABIs/aUSDC.json";
import debtusdcABI from "./ABIs/varDebtUSDC.json";
import aaveLogo from "./img/aave-cd.png";
import mmFox from "./img/MetaMask_Fox.png";
import { useNavigate } from "react-router-dom";
import usdc from "./img/usdc.png";
import { Link } from "react-router-dom";

function Home() {
  const [currentAccount, setCurrentAccount] = useState(null);
  const [USDCamount, setUSDCamount] = useState(null);
  const [aUSDCamount, setaUSDCamount] = useState(null);
  const [debtUSDCamount, setdebtUSDCamount] = useState(null);
  const navigate = useNavigate();

  const USDCAbi = usdcABI;
  const USDCAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const aUSDCAbi = ausdcABI;
  const aUSDCAddr = "0x935c0F6019b05C787573B5e6176681282A3f3E05";
  const debtUSDCAbi = debtusdcABI;
  const debtUSDCAddr = "0xcfc2d9b9498cBd6F71E5E46d46082C76C4F6C695";
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const multiplier = 10 ** 6;
  const USDCContract = new ethers.Contract(USDCAddr, USDCAbi, signer);
  const aUSDCContract = new ethers.Contract(aUSDCAddr, aUSDCAbi, signer);
  const debtUSDCContract = new ethers.Contract(
    debtUSDCAddr,
    debtUSDCAbi,
    signer
  );

  const connectWalletHandler = async () => {
    const { ethereum } = window;

    const accounts = await ethereum.request({ method: "eth_requestAccounts" });
    const newUSDCamount = await USDCContract.balanceOf(accounts[0]);
    const newaUSDCamount = await aUSDCContract.balanceOf(accounts[0]);
    const newDebtUSDCamount = await debtUSDCContract.balanceOf(accounts[0]);
    setCurrentAccount(accounts[0]);
    setUSDCamount((newUSDCamount / multiplier).toString());
    setaUSDCamount((newaUSDCamount / multiplier).toString());
    setdebtUSDCamount((newDebtUSDCamount / multiplier).toString());
  };

  const connectWalletButton = () => {
    return (
      <div className="mm-button">
        <button onClick={connectWalletHandler} className="button-4">
          <img src={mmFox} width={20} height={20}></img>
          Connect Wallet
        </button>
      </div>
    );
  };

  const goToDeleg = () => {
    navigate("/delegate");
  };

  const goToBorrow = () => {
    navigate("/borrow");
  };

  const goToSupply = () => {
    navigate("/supply");
  };

  const handleClick = () => {
    return (
      <div className="App">
        <p>Connected to : {currentAccount}</p>
        <p>
          Wallet : {USDCamount} USDC
          <br />
          Supplied : {aUSDCamount} USDC
          <br />
          Borrowed : {debtUSDCamount} USDC
        </p>
        <p>I want to </p>
        <div className="delegate-or-borrow">
          <div className="borrow-btn">
            <button onClick={goToSupply} className="button-4">
              Supply
              <img
                src={usdc}
                width={20}
                height={20}
                className="usdc"
              ></img>USDC{" "}
            </button>
          </div>
          <div className="borrow-btn">
            <button onClick={goToDeleg} className="button-4">
              Delegate
              <img src={usdc} width={20} height={20} className="usdc"></img>USDC
            </button>
          </div>
          <div className="borrow-btn">
            <button onClick={goToBorrow} className="button-4">
              Borrow
              <img
                src={usdc}
                width={20}
                height={20}
                className="usdc"
              ></img>USDC{" "}
            </button>
          </div>
        </div>
        <div>
          <br />
          <br />
          <a
            className="Approve"
            href="https://goerli.etherscan.io/token/0x9FD21bE27A2B059a288229361E2fA632D8D2d074?a=0x036fEb0867B6873Dc281727689Bc47Fd810f6044#writeContract"
          >
            Mint USDC
          </a>
        </div>
      </div>
    );
  };

  return (
    <div className="App">
      <div className="App-header">
        <Link to="/">
          <img src={aaveLogo}></img>
        </Link>
      </div>
      {currentAccount ? handleClick() : connectWalletButton()}
    </div>
  );
}

export default Home;
