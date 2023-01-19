import { useState } from "react";
import { GelatoOpsSDK, isGelatoOpsSupported, TaskTransaction } from "@gelatonetwork/ops-sdk";
import { Contract } from "ethers";
import { ethers } from "ethers";
import counterAbi from "../abis/CounterTest.json";

function Automate(){

    async function CreateTask(){
        // const providerUrl = "https://eth-goerli.g.alchemy.com/v2/"
        // let provider = ethers.getDefaultProvider("goerli");
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();

        const networkDetails = await provider.getNetwork();
        const chainId = networkDetails.chainId;

        // let signer = provider.getSigner();


        if (!isGelatoOpsSupported(chainId)) {
            console.log(`Gelato Ops network not supported (${chainId})`);
            return;
        }

        const gelatoOps = new GelatoOpsSDK(chainId, signer);
        const counter = new Contract("0x69C904fed91BFe2a354DbDd1A1078485389Fe6E9", counterAbi, signer);
        const selector = counter.interface.getSighash("increaseCount(uint256)");
        const resolverData = counter.interface.getSighash("checker()");

            // Create task
            console.log("Creating Task...");
            const { taskId, tx } = await gelatoOps.createTask({
                execAddress: counter.address,
                execSelector: selector,
                execAbi: JSON.stringify(counterAbi),
                resolverAddress: counter.address,
                resolverData: resolverData,
                resolverAbi: JSON.stringify(counterAbi),
                name: "Automated counter with resolver",
                dedicatedMsgSender: true,
            });
            await tx.wait();
            console.log(`Task created, taskId: ${taskId} (tx hash: ${tx.hash})`);
            console.log(`> https://app.gelato.network/task/${taskId}?chainId=${chainId}`);   
    }

        return(
        <div className="automation">
            <button onClick={CreateTask}>Create Task</button>
        </div>
    );
}

export default Automate;

