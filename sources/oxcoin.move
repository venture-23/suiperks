module oxdao::oxcoin {
    use sui::coin::{Self, TreasuryCap};
    use oxdao::oxdao_nft::{OxDaoNFT};
    use oxdao::icon::{get_icon_url};
    use sui::table::{Self, Table};
    use sui::event;

    //const EAlreadyClaimed: u64 = 100; 
    //const EVoterNotExist: u64 = 101; 
    const ECannotMintMAXSUPPLY: u64 = 101;
    const ERewardClaimPause: u64 = 102;
    const ENotEligibleForReward: u64 = 103;
    const EAlreadyPaused: u64 = 104;
    const EAlreadyResume: u64 = 105;

    public struct OXCOIN has drop {}

    public struct AdminCap has key, store {
        id: UID, 
    }

    const TotalSupply: u64 =  60_000_000_000_000_000; 


    public struct Directory has key, store {
        id: UID, 
        paused: bool, 
        total_minted: u64, 
        treasury:  TreasuryCap<OXCOIN>, 
        top_one_list: Table<address, u64>, 
        top_two_list: Table<address, u64>, 
        top_three_list: Table<address, u64>,
    }  

    public struct RewardClaimed has copy, store, drop{
        claimed_id: address,
        claimed_amount: u64,
        total_reward_minted: u64,  
    }

    // == Initialization == 
    fun init(witness: OXCOIN, ctx: &mut TxContext) {
        let (treasury_cap, metadata ) = coin::create_currency(
            witness,
            9, 
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
            total_minted: 0u64,
            treasury: treasury_cap, 
            top_one_list: table::new(ctx),
            top_two_list: table::new(ctx), 
            top_three_list: table::new(ctx),
        }; 
        transfer::public_share_object(directory); 
        let adminCap = AdminCap{
            id: object::new(ctx), 
        };
        transfer::transfer(adminCap, ctx.sender()); 
     }

    public fun admin_pause( 
        directory: &mut Directory,
        _: &AdminCap, 
    ) {
        assert!(directory.paused == false, EAlreadyPaused);
        directory.paused = true; 
    }
    public fun admin_resume( 
        directory: &mut Directory,
        _: &AdminCap, 
    ) {
        assert!(directory.paused == true, EAlreadyResume);
        directory.paused = false;
    }

    #[allow(lint(self_transfer))]    
    public fun claim_voter_reward(
        directory: &mut Directory, 
        _nft_id: &OxDaoNFT, 
        ctx: &mut TxContext
    ){
        let sender = tx_context::sender(ctx);
        assert!(!directory.paused, ERewardClaimPause);
        assert!(table::contains(&directory.top_one_list, sender) || table::contains(&directory.top_two_list, sender) ||(table::contains(&directory.top_three_list, sender)), ENotEligibleForReward);
        if(table::contains(&directory.top_one_list, sender)){
            let amount = table::borrow(&directory.top_one_list, sender);
            let coin = coin::mint<OXCOIN>(&mut directory.treasury, *amount, ctx);
            let coin_value = coin::value(&coin);
            assert!(coin_value < TotalSupply, ECannotMintMAXSUPPLY);
            transfer::public_transfer(coin, ctx.sender());
            table::remove(&mut directory.top_one_list, sender);
            directory.total_minted = directory.total_minted + coin_value;
            event::emit(RewardClaimed{
                claimed_id: ctx.sender(), 
                claimed_amount: coin_value,
                total_reward_minted: directory.total_minted,
            });
        };
        if(table::contains(&directory.top_two_list, sender)){
            let amount = table::borrow(&directory.top_two_list, sender);
            let coin = coin::mint<OXCOIN>(&mut directory.treasury, *amount, ctx);
            let coin_value = coin::value(&coin);
            assert!(coin_value < TotalSupply, ECannotMintMAXSUPPLY);
            transfer::public_transfer(coin, ctx.sender());
            table::remove(&mut directory.top_two_list, sender);
            directory.total_minted = directory.total_minted + coin_value;
            event::emit(RewardClaimed{
                claimed_id: ctx.sender(), 
                claimed_amount: coin_value,
                total_reward_minted: directory.total_minted,
            });
        };
        if(table::contains(&directory.top_three_list, sender)){
            let amount = table::borrow(&directory.top_three_list, sender);
            let coin = coin::mint<OXCOIN>(&mut directory.treasury, *amount, ctx);
            let coin_value = coin::value(&coin);
            assert!(coin_value < TotalSupply, ECannotMintMAXSUPPLY);
            transfer::public_transfer(coin, ctx.sender());
            table::remove(&mut directory.top_three_list, sender);
            directory.total_minted = directory.total_minted + coin_value;
            event::emit(RewardClaimed{
                claimed_id: ctx.sender(), 
                claimed_amount: coin_value,
                total_reward_minted: directory.total_minted,
            });
        };
    }
    
    public fun add_top_one_voter_list(
        _: &AdminCap,
        directory: &mut Directory,
        top_voter: address, 
        amount: u64, 
    ){
        table::add(&mut directory.top_one_list, top_voter, amount); 
    } 

    public fun add_top_two_voter_list(
        _: &AdminCap,
        directory: &mut Directory,
        top_voter: address, 
        amount: u64, 
    ){
        table::add(&mut directory.top_two_list, top_voter, amount); 
    } 

    public fun add_top_three_voter_list(
        _: &AdminCap,
        directory: &mut Directory,
        top_voter: address, 
        amount: u64, 
    ){
        table::add(&mut directory.top_three_list, top_voter, amount); 
    } 
}