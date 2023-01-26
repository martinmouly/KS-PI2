import "./App.css";
import { ethers } from "ethers";
import { useEffect, useState } from "react";
import aaveLogo from "./img/aave-cd.png";
import LendingPoolABI from "./ABIs/lendingPool.json";
import usdcABI from "./ABIs/usdc.json";
import usdc from "./img/usdc.png";
import { Link } from "react-router-dom";

function Supply() {
  const [amount, setAmount] = useState(null);

  const assetAbi = usdcABI;
  const assetAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const poolAbi = LendingPoolABI;
  const poolAddr = "0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210";
  const multiplier = 10 ** 6;
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const assetContract = new ethers.Contract(assetAddr, assetAbi, signer);
  const poolContract = new ethers.Contract(poolAddr, poolAbi, signer);

  function handleSubmit(event) {
    event.preventDefault();
    checkApproveAndSupply();
  }

  function checkApproveAndSupply() {
    const checkAllowance = assetContract.allowance(
      signer.getAddress(),
      poolAddr
    );

    checkAllowance.then((value) => {
      if (value.gte(amount * multiplier) == true) {
        poolContract.deposit(
          assetAddr,
          amount * multiplier,
          signer.getAddress(),
          0
        );
      } else {
        window.alert("You need to approve before supplying token");
      }
    });
  }

  function callApprove() {
    assetContract.approve(
      poolAddr,
      ethers.BigNumber.from(
        "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
      )
    );
  }

  return (
    <div className="App">
      <div className="App-header">
        <Link to="/">
          <img src={aaveLogo}></img>
        </Link>
      </div>
      <div className="Approve">
        <a onClick={callApprove}>Approve token</a>
      </div>
      <form className="form-box" onSubmit={handleSubmit}>
        <input
          placeholder="Amount"
          value={amount}
          onChange={(event) => setAmount(event.target.value)}
        />
        <br></br>
        <button className="button-4">
          Supply
          <img
            src={usdc}
            width={20}
            height={20}
            className="usdc"
          ></img>USDC{" "}
        </button>
      </form>
    </div>
  );
}

export default Supply;
