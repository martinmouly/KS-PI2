import React, { useCallback, useEffect, useRef, useState } from 'react';
import { ethers } from "ethers";
import { connectWallet } from "./Wallet.js";


// connect metamask wallet with etherjs


export default function Intro(){
    if(connectWallet());

    return(
        <div>
            <div>
            <h1>Welcome to our Website !</h1>
            </div>
        </div>
    )
}