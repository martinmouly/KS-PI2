
// allow the user to see : 
// 1. how much of all tokens they have borrowed from QiDAO
// 2. how much tokens they delegated to other users
// 3.a  how much each addresses borrowed from them and buttons to edit their rigths 
// 3.b how much the current user borrowed from each address + button to repay / borrow more
// 4. how much tokens they can withdraw now + button to withdraw
// 5. health and liquidation price + button to add collateral
// 6. button to delegate or borrow to another user

import { ethers } from 'ethers';
import { connectWallet, getAddress } from "./Wallet.js";


// contracts addresses
const contractAddresses = require('./contractAddresses.json')
const delegationAddress = contractAddresses.delegation

// contract abi
const delegationAbi = require('../abis/delegationAbi.json')

// contracts initialisation
const provider = new ethers.providers.Web3Provider(window.ethereum);
const delegationContract = new ethers.Contract(delegationAddress, delegationAbi['abi'], provider);
 

async function getDepositedValue(address, token){ 
    return await delegationContract.getDepositedValue(address, token);
}

export default function DelegationDashboard() {
    // check if the user is connected to metamask
    // if not, redirect to the intro page
    if(!connectWallet()) {
        window.location.href = "/intro";
    }

    // get the user's address
    const userAddress = getAddress();

    // get the user's qiDAO deposit value locked in our contract
    // if the user has no balance, ask if he wants to borrow
    // if the user has a balance, display the usual dashboard
    


    

    return(
        <div>
            <p>{delegationAddress}</p>
        </div>
    )
}
