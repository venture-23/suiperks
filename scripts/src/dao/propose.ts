import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../../utils/execStuff';
import { packageId, NftId, Dao} from '../../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
import { inspect } from 'util';

dotenv.config();

async function create_proposal() {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();
    let proposal = tx.moveCall({
        target: `${packageId}::ethena_dao::propose`,
        arguments: [
            tx.object(Dao),  // Dao<DaoWitness>
            tx.object(NftId), // 0xDaoNFT, 
            tx.object(SUI_CLOCK_OBJECT_ID), // quorum_votes, 
            tx.pure.string('754f32722ce2c9de3117a9273080bc58689b3846baada394ba352be3'), // hash proposal title/content
            tx.pure.u64(100000), // seek_amount
        ],
    });
    tx.moveCall({
        target: `${packageId}::ethena_dao::add_proposal_dynamically`,
        arguments: [
            tx.object(Dao), 
            proposal
        ], 
    });
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest);
    const digest_ = result.digest;

    const txn = await client.getTransactionBlock({
        digest: String(digest_),
        // only fetch the effects and objects field
        options: {
            showEffects: true,
            showInput: false,
            showEvents: false,
            showObjectChanges: true,
            showBalanceChanges: false,
        },
    });
    let output: any;
    output = txn.objectChanges;
    let ProposalId;
    for (let i = 0; i < output.length; i++) {
        const item = output[i];
        if (await item.type === 'created') {
            if (await item.objectType === `${packageId}::ethena_dao::Proposal`) {
               ProposalId = String(item.objectId);
            }
        }
    }
    console.log(`ProposalId: ${ProposalId}`);
}
create_proposal();