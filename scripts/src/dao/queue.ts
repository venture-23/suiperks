import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../../utils/execStuff';
import { packageId, ProposalId, NftId, Dao} from '../../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
dotenv.config();

async function queue() {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();

    tx.moveCall({
        target: `${packageId}::dao::queue`,
        arguments: [
            tx.object(Dao),
            tx.pure.address("0x701301c564fbc2522b3cc9c3cb9bc0ca2474d461a6344b0b73db31f10c30e713"), // Proposal<DaoWitness> 
            tx.object(SUI_CLOCK_OBJECT_ID), // clock

        ],
    });
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest); 
}
queue();