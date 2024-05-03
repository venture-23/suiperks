import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../utils/execStuff';
import { packageId, AuctionInfo } from '../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
dotenv.config();

async function bid_auction(amount: number) {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();
    const coin = tx.splitCoins(tx.gas, [tx.pure(amount)]);
    tx.moveCall({
        target: `${packageId}::auction::bid`,
        arguments: [
            tx.object(AuctionInfo),
            tx.object(SUI_CLOCK_OBJECT_ID),
            coin,
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
    const digest_ = result.digest;

    const txn = await client.getTransactionBlock({
        digest: String(digest_),
        // only fetch the effects and objects field
        options: {
            showEffects: true,
            showInput: false,
            showEvents: true,
            showObjectChanges: true,
            showBalanceChanges: false,
        },
    });
    let output: any;
    output = txn.objectChanges;
    // let AuctionInfo;
    // for (let i = 0; i < output.length; i++) {
    //     const item = output[i];
    //     if (await item.type === 'created') {
    //         if (await item.objectType === `${packageId}::auction::AuctionInfo<0x2::sui::SUI>`) {
    //            AuctionInfo = String(item.objectId);
    //         }
    //     }
    // }
    // console.log(`AuctionInfo: ${AuctionInfo}`);
}

bid_auction(110250000);