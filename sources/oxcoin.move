module oxdao::oxcoin {
    use sui::coin::{Self, TreasuryCap};
    use sui::table::{Self, Table}; 
    use oxdao::oxdao_nft::{OxDaoNFT};
    use oxdao::icon::{get_icon_url};

    const EAlreadyClaimed: u64 = 100; 
    const EVoterNotExist: u64 = 101; 
    const ERewardClaimPause: u64 = 102;

    public struct OXCOIN has drop {}

    public struct AdminCap has key, store {
        id: UID, 
    }

    public struct Directory has key, store {
        id: UID, 
        paused: bool, 
        proposal_count: u64, 
        treasury:  TreasuryCap<OXCOIN>, 
        voter_counter: Table<ID, u64>, 
        reward_list: vector<ID>,
    } 

    public struct Stats has key, store {
        id: UID, 
        voter_stats: Table<ID, u64>
    }

    // == Initialization == 
    fun init(witness: OXCOIN, ctx: &mut TxContext) {
        let (treasury_cap, metadata ) = coin::create_currency(
            witness,
            8, 
            b"OXCOIN", 
            b"Oxy Coin", 
            b"Oxy Coin for voters", 
            option::some(get_icon_url()), 
            ctx
        );
        transfer::public_freeze_object(metadata); 
        let directory = Directory {
            id: object::new(ctx), 
            paused: false, 
            proposal_count: 0u64,
            treasury: treasury_cap, 
            voter_counter: table::new(ctx),
            reward_list: vector::empty(),
        }; 
        transfer::public_share_object(directory); 
        let adminCap = AdminCap{
            id: object::new(ctx), 
        };
        let stats = Stats{
            id: object::new(ctx), 
            voter_stats: table::new(ctx),
        };
        transfer::transfer(adminCap, ctx.sender()); 
        transfer::share_object(stats);
     }

    public fun admin_pause( 
        directory: &mut Directory,
        _: &AdminCap, 
    ) {
        directory.paused = true; 
    }
    public fun admin_resume( 
        directory: &mut Directory,
        _: &AdminCap, 
    ) {
        directory.paused = false;
    }

    public(package) fun increase_voter_vote_count(directory: &mut Directory, nft_id: &OxDaoNFT){
        if(table::contains(&directory.voter_counter, object::id(nft_id))){
           let count = table::remove(&mut directory.voter_counter, object::id(nft_id));
           table::add(&mut directory.voter_counter, object::id(nft_id), count+1);
        }
        else {
        table::add(&mut directory.voter_counter, object::id(nft_id), 1);
        }
    }

    public(package) fun decrease_voter_vote_count(directory: &mut Directory, nft_id: &OxDaoNFT){
        assert!(table::contains(&directory.voter_counter, object::id(nft_id)), EVoterNotExist); 
        let count = table::remove(&mut directory.voter_counter, object::id(nft_id));
        table::add(&mut directory.voter_counter, object::id(nft_id), count - 1);
        
    }

    #[allow(lint(self_transfer))]    
    public fun claim_voter_reward(
        directory: &mut Directory, 
        nft_id: &OxDaoNFT, 
        stats: &mut Stats,
        ctx: &mut TxContext
    ){
        assert!(!directory.paused, ERewardClaimPause);
        assert!(!vector::contains(&directory.reward_list, &object::id(nft_id)), EAlreadyClaimed);
        let coin = coin::mint<OXCOIN>(&mut directory.treasury, 100000000, ctx);
        let coin_value = coin::value(&coin);
        vector::push_back(&mut directory.reward_list, object::id(nft_id));
        if(!table::contains(&stats.voter_stats, object::id(nft_id))){
            table::add(&mut stats.voter_stats, object::id(nft_id), coin_value);
            transfer::public_transfer(coin, ctx.sender());
        }
        else{
            let value = table::remove(&mut stats.voter_stats, object::id(nft_id)); 
            let updated_value = value + coin_value;
            table::add(&mut stats.voter_stats, object::id(nft_id), updated_value);
            transfer::public_transfer(coin, ctx.sender());
        }
    }
}