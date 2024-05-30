import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../../utils/execStuff';
import { packageId, ProposalId, NftId, Dao} from '../../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
dotenv.config();

async function cast_vote() {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();

    tx.moveCall({
        target: `${packageId}::ethena_dao::cast_vote`,
        arguments: [
            tx.object(Dao),
            tx.pure.address("0x54f6f317f540b227aa3b7cbc0deaaa05c3192dff52f246680341a5d8aab4cbfd"), // Proposal<DaoWitness> 
            tx.object(NftId), // 0xDaoNft
            tx.object(SUI_CLOCK_OBJECT_ID), // clock
            tx.pure.bool(true), // yes or no vote 

        ],
    });
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest); 
}
cast_vote();