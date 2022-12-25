import { ethers } from 'ethers';


async function connectWallet() {
    var connected = false;
    try{
        window. ethereum.enable() ;
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const address = await signer.getAddress();
        console.log(address);
        connected = true;
    }catch(err){
        console.log(err);
    }
    return connected;   
}

async function getAddress(){
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const address = await signer.getAddress();
    return address;
}

export { connectWallet, getAddress };