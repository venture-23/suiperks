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
        target: `${packageId}::dao::revoke_vote`,
        arguments: [
            tx.object(Dao),
            tx.pure.address("0x7049e356a02cb899a7ce8cd45127a277f9103c8af10b9235ecfd26ad145dc696"), // Proposal<DaoWitness> 
            tx.object(NftId), // clock
            tx.object(SUI_CLOCK_OBJECT_ID),
        ],
    });
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest); 
}
queue();