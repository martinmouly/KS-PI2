import {useState} from "react";
import Card from "./Card/Card";


const Login = (props) => {
    
    const [isConnecting, setIsConnecting] = useState(false);
    const [isConnected, setIsConnected] = useState(false);

    const detectProvider = () => {
        let provider;
        if(window.ethereum) {
            provider = window.ethereum;
        }
        else if (window.web3) {
            provider = window.web3.currentProvider;
        }
        else
        {
            window.alert("No Ethereum browser detected! Check out MetaMask");
        }
        return provider;
    };

    const onLoginHandler = async () => {
        const provider = detectProvider();
        if (provider) {
            if (provider !== window.ethereum) {
                console.error("Not window.ethereum provider. Do you have multiple wallets installed ?")
            }
            setIsConnecting(true);
            await provider.request({
                method: "eth_requestAccounts",
            });
            setIsConnecting(false);
            props.onLogin(provider);
        }
    };

    return (
        <Card>
            <button onClick={onLoginHandler} type="button">
                {!isConnecting && "Connect"}
                {isConnecting && "Loading..."}
            </button>
        </Card>
    );
}

export default Login;