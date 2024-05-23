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
            tx.pure.string('https://cdn.leonardo.ai/users/84487ea6-407f-45f2-952f-05212bc952a4/generations/0208653b-fdf6-4bec-9c52-1b649f9262df/variations/Default_Japanese_tshirt_designs_like_tattoos_full_of_pictures_2_0208653b-fdf6-4bec-9c52-1b649f9262df_1.jpg?w=512'),
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