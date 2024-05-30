import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../utils/execStuff';
import { packageId, NftId, Admincap, Directory} from '../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
dotenv.config();

async function add_top_one_voter_list() {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();
    const address = ['0x16b80901b9e6d3c8b5f54dc8a414bb1a75067db897e7a3624793176b97445ec6', '0x821febff0631744c231a0f696f62b72576f2634b2ade78c74ff20f1df97fc9bf'];
    const amount = [1000000000, 100000000];

    for(let i=0; i< address.length; i++){
    tx.moveCall({
        target: `${packageId}::oxcoin::add_top_one_voter_list`,
        arguments: [
            tx.object(Admincap),
            tx.object(Directory), // Proposal<DaoWitness> 
            tx.pure.address(address[i]), // 0xDaoNft
            tx.pure.u64(amount[i])

        ],
    });
    }
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest); 
}
add_top_one_voter_list();