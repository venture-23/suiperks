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
            tx.pure.address("0x1b3df18cbb35c8d7e8b69e767be1db529c93181404edf0740607a3f0f203fe90"), // Proposal<DaoWitness> 
            tx.object(NftId), // 0xDaoNft
            tx.object(SUI_CLOCK_OBJECT_ID), // clock
            tx.pure.bool(false), // yes or no vote 

        ],
    });
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest); 
}
cast_vote();