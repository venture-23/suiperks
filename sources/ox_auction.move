module oxdao::auction {
    use std::option::{Self, Option};
    use sui::coin::{Self, Coin}; 
    use sui::sui::SUI;
    use sui::table::{Self, Table};
    use std::string::{Self, String};
    use sui::balance::{Self, Balance};
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

    public struct Treasury<phantom T> has key, store {
        id: UID,
        name: String,
        treasury_amount: Balance<T>,
    }

    public struct AuctionEvent has copy, drop { 
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
}