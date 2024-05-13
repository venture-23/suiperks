import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../../utils/execStuff';
import { packageId, DaoTreasury} from '../../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
dotenv.config();

async function create_event() {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();  

    tx.moveCall({
        target: `${packageId}::ethena_dao::create_dao`,
        arguments: [
            tx.pure.u64(1*60*1000), // voting _delay 
            tx.pure.u64(3*60*1000), // voting period 
            tx.pure.u64(1_000_000_000), // voting_quorun_rate
            tx.pure.u64(1*60*1000),//  min_action_delay
            tx.pure.u64(4), // min_quorum_votes
        ],
        // typeArguments:[
        //     `${packageId}::dao::Proposal`
        // ]
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
    let Dao;
    for (let i = 0; i < output.length; i++) {
        const item = output[i];
        if (await item.type === 'created') {
            if (await item.objectType === `${packageId}::ethena_dao::Dao`) {
               Dao = String(item.objectId);
            }
        }
    }
    console.log(`Dao: ${Dao}`);
}
create_event();