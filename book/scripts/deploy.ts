// scripts/deploy.ts
import { StacksMainnet, StacksTestnet } from '@stacks/network';
import { readFileSync } from 'fs';
import {
    makeContractDeploy,
    broadcastTransaction,
    AnchorMode,
    standardPrincipalCV,
    stringUtf8CV,
    uintCV
} from '@stacks/transactions';
import { getPrivateKey, getNetwork } from './utils/config';

async function deployContract() {
    const networkType = process.env.NETWORK_TYPE || 'testnet';
    const network = networkType === 'mainnet' ? new StacksMainnet() : new StacksTestnet();
    const privateKey = getPrivateKey();
    
    // Read contract source
    const contractSource = readFileSync('./contracts/medical-analysis.clar').toString();
    
    // Create contract deploy transaction
    const deployTx = await makeContractDeploy({
        contractName: 'medical-analysis',
        codeBody: contractSource,
        senderKey: privateKey,
        network,
        anchorMode: AnchorMode.Any,
        fee: 10000,
        postConditionMode: 0x01
    });
    
    try {
        // Broadcast the transaction
        const txResult = await broadcastTransaction(deployTx, network);
        console.log('Transaction ID:', txResult.txid);
        return txResult;
    } catch (err) {
        console.error('Deployment failed:', err);
        throw err;
    }
}

// Initialize deployment
if (require.main === module) {
    deployContract()
        .then(() => process.exit(0))
        .catch((err) => {
            console.error(err);
            process.exit(1);
        });
}
