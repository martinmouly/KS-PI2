import Card from "./Card/Card";

const ChainInfo = (props) => {
    return ( 
        <Card>
            <h1>Welcome, here are some infos</h1>
            <p>You are connected with : {props.currentAccount}</p>
        </Card>
    );
};

export default ChainInfo;