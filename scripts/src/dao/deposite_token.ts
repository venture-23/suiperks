import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../../utils/execStuff';
import { packageId, ProposalId, NftId, Dao, DaoTreasury} from '../../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
dotenv.config();

async function deposit(amount: number) {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();
    const coin = tx.splitCoins(tx.gas, [tx.pure(amount)]);
    tx.moveCall({
        target: `${packageId}::treasury::deposite_coin_from_auction`,
        arguments: [
            tx.object(DaoTreasury), // clock
            coin
        ],
        typeArguments: [
            '0x2::sui::SUI'
        ]
    });
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
    });
    console.log(result.digest); 
}
deposit(5000000000);