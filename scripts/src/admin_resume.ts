import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../utils/execStuff';
import { packageId, Admincap, Directory} from '../utils/packageInfo';
dotenv.config();

async function admin_pause() {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();

    tx.moveCall({
        target: `${packageId}::oxcoin::admin_resume`,
        arguments: [
            tx.object(Directory), // Proposal<DaoWitness> 
            tx.object(Admincap),
        ],
    });
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest); 
}
admin_pause();