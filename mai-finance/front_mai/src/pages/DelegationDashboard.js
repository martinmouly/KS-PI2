
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
import { getLockedValue } from "./interactWithOurContract.js";


// contracts addresses
const contractAddresses = require('../data/contractAddresses.json')
const delegationAddress = contractAddresses.delegation

// contract abi
const delegationAbi = require('../abis/delegationAbi.json')

// contracts initialisation
const provider = new ethers.providers.Web3Provider(window.ethereum);
const delegationContract = new ethers.Contract(delegationAddress, delegationAbi['abi'], provider);
 

async function lockedValueDashboard(userAddress){
    function yesButton() {
        //window.location.href = "/initialDeposit";
    }
    function noButton() {
        window.location.href = "/delegationDashboard"; // boucle infinie, doit rajouter un argument pour forcer l'affichage du dashboard
    }
    const vault = require('../data/vault.json')
    const vaultList = vault.names;
    const valueInVault = false; // in the next for loop, if the user has a balance in a vault, set this to true. if not, ask if he wants to deposit
    const valueLocked = [];
    const lockedValue = 0;
    for (let i = 0; i < vaultList.length; i++) {
        const lockedValue = getLockedValue(userAddress, vault[i]);
        if(lockedValue > 0){
            valueInVault = true;
        }
        // push valueLocked with lockedValue
        valueLocked.push(lockedValue);
    }
    // if the user has no balance, ask if he wants to borrow
    if (!valueInVault){
        // ask if he wants to deposit
        // si oui, on l'envoie sur une page de deposit (possibilité de déposer des nfts qu'il possède ou de déposer sur mai finance et d'automatiquement envoyer le nft sur notre contrat) (le tout en 1 transaction)
        return(
            <div>
                <p>you have no balance in any vault. do you want to deposit ?</p>
                <button id='goInitialDeposit' onClick={yesButton}>Yes</button><button id='' onClick={noButton}>No</button> 
            </div>
        )
    }
    else{
        // display the usual dashboard
        return(
            <div>
                <p>here is your Vault : </p>
                <p>You have {lockedValue[0].toString()} WBTC locked in our contract</p>
                <p>You have {lockedValue[1].toString()} WETH locked in our contract</p>
            </div>
        )
    }
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
    const lockedValue = lockedValueDashboard(userAddress);

    // if the user has a balance, display the usual dashboard
    


    

    return(
        <div>
            <p>{delegationAddress}</p>
        </div>
    )
}
