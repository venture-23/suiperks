module oxdao::oxdao_nft {
    use std::string::{utf8, String};
    use sui::event;
    use sui::package;
    use sui::display;
    use sui::dynamic_field::{Self as df};
    
    public struct OXDAO_NFT has drop { }
    
    public struct OxDaoNFT has key, store {
        id: UID,
        /// Name for the token
        name: String,
        /// Description of the token
        description: String,
        /// URL for the token
        url: String,
    }

    public struct OxDaoNFTEvent has copy, drop {
        // The Object ID of the NFT
        object_id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: String,
    }

    fun init(
        otw: OXDAO_NFT, 
        ctx: &mut TxContext
    ) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"description"), 
            utf8(b"url"),
        ];
        let values = vector[
            utf8(b"{name}"), 
            utf8(b"{description}"),
            utf8(b"{url}"), 
        ];
        let publisher = package::claim(otw, ctx); 
        let mut display = display::new_with_fields<OxDaoNFT>(
            &publisher, keys, values, ctx
        );
       
        display::update_version(&mut display);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }


    public(package) fun create_nft(
        name: String,
        description: String,
        url: String,
        ctx: &mut TxContext
    ): OxDaoNFT {
        let nft = OxDaoNFT {
            id: object::new(ctx),
            name,
            description,
            url        
        };
        let sender = tx_context::sender(ctx);
        event::emit(OxDaoNFTEvent {
            object_id: object::uid_to_inner(&nft.id),
            creator: sender,
            name: nft.name,
        });
        nft
    }

    public(package) fun dynamically_add_price(nft: &mut OxDaoNFT, name: String, price: u64) {
        df::add(&mut nft.id, name, price);
    }

    public(package) fun get_price_detail(nft: &OxDaoNFT, name: String): &u64{
        let value = df::borrow(&nft.id, name);
        value
    }
}