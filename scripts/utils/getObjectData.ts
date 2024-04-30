import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";


export async function objectDetails(obj: any, version: any) {
    const client = new SuiClient({
        url: getFullnodeUrl("testnet"),
    });

    try {
        const txn = await client.tryGetPastObject({
            id: obj,
            version: version,
        });
        //let data: any = txn.data;
        let data = txn;
        //let fields = data.details;
        console.log(data);
        //return fields;
    } catch (error) {
        console.error(error);
        throw error;
    }
}