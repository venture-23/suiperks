import { TransactionBlock } from '@mysten/sui.js/transactions';
import * as dotenv from 'dotenv';
import getExecStuff from '../utils/execStuff';
import { packageId, DaoTreasury, AuctionInfo, AuctionDetails } from '../utils/packageInfo';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';
dotenv.config();

async function settle_bid() {

    const { keypair, client } = getExecStuff();
    const tx = new TransactionBlock();

    tx.moveCall({
        target: `${packageId}::auction::settle_bid`,
        arguments: [
            tx.object(AuctionDetails),
            tx.pure.string('OxNFT #1'),
            tx.pure.string('random description'),
            tx.pure.string('https://content.coolcatsnft.com/wp-content/uploads/2023/08/Blue-2.png'),
            tx.object(DaoTreasury),
            tx.object(AuctionInfo),
            tx.object(SUI_CLOCK_OBJECT_ID)
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
            showEvents: false,
            showObjectChanges: true,
            showBalanceChanges: false,
        },
    });
    let output: any;
    output = txn.objectChanges;
    let OxNFT;
    for (let i = 0; i < output.length; i++) {
        const item = output[i];
        if (await item.type === 'created') {
            if (await item.objectType === `${packageId}::oxdao_nft::OxDaoNFT`) {
                OxNFT = String(item.objectId);
            }
        }
    }
    console.log(`OxNFT: ${OxNFT}`);
}
settle_bid();