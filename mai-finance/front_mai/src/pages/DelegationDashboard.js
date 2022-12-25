
// allow the user to see : 
// 1. how much of all tokens they have borrowed from QiDAO
// 2. how much tokens they delegated to other users
// 3. how much each addresses borrowed from them and buttons to edit their rigths
// 4. how much tokens they can withdraw now + button to withdraw
// 5. health and liquidation price + button to add collateral
// 6. button to delegate to another user

import { ethers } from 'ethers';
import { connectWallet, getAddress } from "./pages/Wallet.js";

// contracts addresses

// contracts initialisation

 
export default function DelegationDashboard() {
    // check if the user is connected to metamask
    // if not, redirect to the intro page
    if(!connectWallet()) {
        window.location.href = "/intro";
    }

    // get the user's address
    const userAddress = getAddress();





}
