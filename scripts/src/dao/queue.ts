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
        target: `${packageId}::ethena_dao::queue`,
        arguments: [
            tx.object(Dao),
            tx.pure.address("0x79741a833c6a7345986529e828256f640c3531762d735c3068483e814d452388"), // Proposal<DaoWitness> 
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