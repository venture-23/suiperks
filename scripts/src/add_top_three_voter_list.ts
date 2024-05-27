import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../utils/execStuff';
import { packageId, NftId, Admincap, Directory} from '../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
dotenv.config();

async function add_top_three_voter_list() {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();

    tx.moveCall({
        target: `${packageId}::oxcoin::add_top_three_voter_list`,
        arguments: [
            tx.object(Admincap),
            tx.object(Directory), // Proposal<DaoWitness> 
            tx.pure.address(NftId), // 0xDaoNft
            tx.pure.u64('1000000000')

        ],
    });
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest); 
}
add_top_three_voter_list();