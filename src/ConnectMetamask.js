import React from "react";
import { ethers } from "ethers";
import "./ConnectMetamask.css";

class ConnectMetamask extends React.Component {
  constructor(props) {
    super(props);
    this.connectHandler = this.connectHandler.bind(this);
    this.accountChangedHandler = this.accountChangedHandler.bind(this);
    this.balanceHandler = this.balanceHandler.bind(this);
    this.chainChangedHandler = this.chainChangedHandler.bind(this);
    this.blockNumberHandler = this.blockNumberHandler.bind(this);
    this.signMsgHandler = this.signMsgHandler.bind(this);
    this.state = {
      errorMsg: "",
      addressUser: "-",
      balanceUser: "-",
      buttonText: "Connect to Metamask",
      chain: "-",
      blockNumber: "-",
    };
  }

  connectHandler() {
    if (window.ethereum) {
      window.ethereum
        .request({ method: "eth_requestAccounts" })
        .then((result) => {
          this.accountChangedHandler(result[0]);
        });
    } else {
      this.setState({
        errorMsg: "Please Install Metamask",
      });
    }

    window.ethereum.on("accountsChanged", this.accountChangedHandler); // Maybe better to re-render for a real project.
    window.ethereum.on("chainChanged", this.chainChangedHandler);
  }

  accountChangedHandler(account) {
    this.setState({
      errorMsg: "",
      addressUser: account,
      buttonText: "Connected",
    });
    this.chainChangedHandler();
  }

  balanceHandler() {
    let accounts = this.state.addressUser;
    window.ethereum
      .request({
        method: "eth_getBalance",
        params: [accounts.toString(), "latest"],
      })
      .then((result) => {
        this.setState({
          balanceUser: ethers.utils.formatEther(result),
        });
      });
  }

  chainChangedHandler() {
    this.balanceHandler();
    this.blockNumberHandler();
    window.ethereum.request({ method: "eth_chainId" }).then((result) => {
      let results = parseInt(result, 16);
      let chainName = "Mainnet";
      let error = "";
      if (results === 3) {
        chainName = "Ropsten";
        error = "Wrong network, please connect on Goerli.";
      } else if (results === 1) {
        chainName = "Mainnet";
        error = "Wrong network, please connect on Goerli.";
      } else if (results === 4) {
        chainName = "Rinkeby";
        error = "Wrong network, please connect on Goerli.";
      } else if (results === 5) {
        chainName = "Goerli";
        error = "";
      } else if (results === 42) {
        chainName = "Kovan";
        error = "Wrong network, please connect on Goerli.";
      } else {
        chainName = "Sorry, we don't know this chain.";
        error = "Wrong network, please connect on Goerli.";
      }

      this.setState({
        chain: chainName,
        errorMsg: error,
      });
    });
  }

  blockNumberHandler() {
    window.ethereum.request({ method: "eth_blockNumber" }).then((result) => {
      this.setState({
        blockNumber: parseInt(result, 16),
      });
    });
  }

  signMsgHandler() {
    if (this.state.addressUser !== "-") {
      const message =
        "By signing this message you agree our terms and conditions.\nThanks.";
      window.ethereum.request({
        method: "personal_sign",
        params: [message, this.state.addressUser.toString()],
      });
    } else {
      this.setState({
        errorMsg: "Please Connect your wallet first",
      });
    }
  }

  render() {
    return (
      <div>
        <h3>Connection Using window.ethereum on Chain : {this.state.chain}</h3>
        <button onClick={this.connectHandler}>{this.state.buttonText}</button>
        <div>Address: {this.state.addressUser}</div>
        <div>Balance: {this.state.balanceUser}</div>
        <div>Last Block : Number #{this.state.blockNumber}</div>
        <button onClick={this.signMsgHandler}>Sign a Message!</button>
        <div className="errorMsg-red">{this.state.errorMsg}</div>
      </div>
    );
  }
}

export default ConnectMetamask;
