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
        target: `${packageId}::ethena_dao::revoke_vote`,
        arguments: [
            tx.object(Dao),
            tx.pure.address("0x078a46216dbb57812c170db50b06b04cf4ac85ec7fd35f66eba5ef975fb24752"), // Proposal<DaoWitness> 
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