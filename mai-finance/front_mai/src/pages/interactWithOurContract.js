import { ethers } from 'ethers';

// contracts addresses
const contractAddresses = require('../data/contractAddresses.json')
const delegationAddress = contractAddresses.delegation

// contract abi
const delegationAbi = require('../abis/delegationAbi.json')

// contracts initialisation
const provider = new ethers.providers.Web3Provider(window.ethereum);
const delegationContract = new ethers.Contract(delegationAddress, delegationAbi['abi'], provider);


async function getLockedValue(userAddress, vault){// get the user's qiDAO deposit value locked in our contract    
    const lockedValue = await delegationContract.maxDelegationCapacity(userAddress, vault);
    return lockedValue;
}

export { getLockedValue };