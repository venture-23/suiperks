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
            tx.object(SUI_CLOCK_OBJECT_ID), // Clock 
            tx.pure.u64(1*60*1000), // action_delay
            tx.pure.u64(4), // quorum_votes, 
            tx.pure.string('hash'), // hash proposal title/content
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