module oxdao::auction {
    use sui::coin::{Self, Coin}; 
    use sui::table::{Self, Table};
    use std::string::{ String};
    use sui::balance::{ Balance};
    use sui::clock::{Self, Clock}; 
    use sui::event;
    use oxdao::oxdao_nft::{Self};
    use oxdao::treasury::{Self, DaoTreasury};
    use std::debug;

    const EAuctionEnded: u64 = 0;
    const ELessthanReservePrice: u64 = 1; 
    const ELessThanLastBidByMinBidIncPercentage: u64 = 2;
    const EAuctionNotEnded: u64 = 3; 
    const ETableSizeNotEqualtoOne: u64 = 4; 

    public struct AuctionInfoEvent has copy, drop {
        auction_id: ID,
        amount: u64,
        reserve_price: u64, 
        duration: u64, // for how long 
        start_time: u64,
        end_time: u64, 
        min_bid_increment_percentage: u64,
    }

    public struct AuctionEvent has copy, drop { 
        current_bid_amount: u64,
        next_auction_amount: u64,
        highest_bidder: address,  
    }

    public struct AuctionInfo<phantom T> has key, store {
        id: UID, 
        amount: u64,
        reserve_price: u64, 
        duration: u64, // for how long 
        start_time: u64,
        end_time: u64, 
        min_bid_increment_percentage: u64,
        funds: Table<address, Balance<T>>,
        highest_bidder: Option<address>,
        settled: bool, 
    }

    public fun create_auction<T>(
        reserve_price: u64, clock: &Clock, ctx: &mut TxContext
    ) {
        // need to handle by cap later 
        // who can create the auction 
        let auction = AuctionInfo<T> {
            id: object::new(ctx),
            amount: 0u64, 
            reserve_price,
            duration: 60000u64, 
            start_time: clock::timestamp_ms(clock), 
            end_time: clock::timestamp_ms(clock) + 600000u64, 
            min_bid_increment_percentage: 5u64,
            funds: table::new(ctx),
            highest_bidder: option::none(),
            settled: false,
        };
        event::emit(AuctionInfoEvent{
            auction_id: object::uid_to_inner(&auction.id), 
            amount: auction.amount,
            reserve_price: auction.reserve_price, 
            duration: auction.duration, // for how long 
            start_time: auction.start_time,
            end_time: auction.end_time, 
            min_bid_increment_percentage: auction.min_bid_increment_percentage,
        });
        transfer::public_share_object(auction);
    }

    public fun bid<T>(auction: &mut AuctionInfo<T>, clock: &Clock, coin: Coin<T>, ctx: &mut TxContext){
        assert!(clock::timestamp_ms(clock) < auction.end_time, EAuctionEnded);
        assert!(coin::value(&coin) >= auction.reserve_price, ELessthanReservePrice);
        let current_bid = auction.amount + ((auction.amount * auction.min_bid_increment_percentage)/ 100);
        assert!(coin::value(&coin) >= current_bid, ELessThanLastBidByMinBidIncPercentage);
        if(option::is_some(&auction.highest_bidder)){
            let lastbidder = option::destroy_some(auction.highest_bidder);
            let refund_amount = table::remove(&mut auction.funds, lastbidder);
            debug::print(&refund_amount);
            transfer::public_transfer(coin::from_balance(refund_amount, ctx), lastbidder);
        };
        let sender = tx_context::sender(ctx);
        let coin_value = coin::value(&coin);
        auction.amount = coin::value(&coin);  
        table::add(&mut auction.funds, sender, coin::into_balance(coin));
        auction.highest_bidder = option::some(sender);
        let next_bid_amount = auction.amount + ((auction.amount * auction.min_bid_increment_percentage)/ 100);
        event::emit(AuctionEvent{
            current_bid_amount:  coin_value,
            next_auction_amount: next_bid_amount, 
            highest_bidder: sender
        });
        debug::print(&auction.highest_bidder);
    }
    public fun settle_bid<T>(name: String, description: String, url: String, treasury: &mut DaoTreasury, auction: &mut AuctionInfo<T>, clock: &Clock, ctx: &mut TxContext) {
        assert!(clock::timestamp_ms(clock) > auction.end_time, EAuctionNotEnded);
        assert!(table::length(&auction.funds) == 1, ETableSizeNotEqualtoOne);
        let winner = option::borrow(&auction.highest_bidder);
        debug::print(winner);
        let amount = table::remove(&mut auction.funds, *winner);
        treasury::deposite_coin_from_auction(treasury, coin::from_balance(amount, ctx));
        let nft = oxdao_nft::create_nft(name,description, url, ctx); 
        auction.settled = true;
        transfer::public_transfer(nft, *winner);
    }
}