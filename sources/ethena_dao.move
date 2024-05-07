/// Module: dao_fund
module oxdao::ethena_dao {

    use sui::table::{Self, Table};
    use std::string::{Self, String};

    const EInvalidQuorumRate: u64 = 1;

    public struct Dao has key, store {
        id: UID,
        voting_delay: u64,
        voting_period: u64,
        voting_quorum_rate: u64,
        min_action_delay: u64, 
        min_quorum_votes: u64,
        proposals_data: Table<ID, address>,
        queued_proposal: Table<ID, bool>,
        executed_proposal: Table<ID, bool>,
        // proposal will be dynamically added here
    }

    public struct Proposal has key, store {
        id: UID,
        proposer: address,
        start_time: u64,
        end_time: u64,
        for_votes: u64,
        against_votes: u64,
        for_voters_list: vector<ID>,
        against_voters_list: vector<ID>,
        eta: u64, 
        action_delay: u64, 
        quorum_votes: u64, 
        voting_quorum_rate: u64, 
        hash: String,
        seek_amount: u64,
        executable: bool,
    }

    // this function needs to be called only once
    public fun create_dao(
        voting_delay: u64, 
        voting_period: u64, 
        voting_quorum_rate: u64, 
        min_action_delay: u64, 
        min_quorum_votes: u64,
        ctx:&mut TxContext) {
        assert!(1_000_000_000 >= voting_quorum_rate && voting_quorum_rate != 0, EInvalidQuorumRate);
        let id = object::new(ctx);
        let dao = Dao{
            id,
            voting_delay,
            voting_period,
            voting_quorum_rate,
            min_action_delay, 
            min_quorum_votes,
            proposals_data: table::new(ctx),
            queued_proposal: table::new(ctx),
            executed_proposal: table::new(ctx),
        };
        transfer::share_object(dao);
    }

    // === Public Dao View Functions ===  
    public fun voting_delay(self: &Dao): u64 {
        self.voting_delay
    }

    public fun voting_period(self: &Dao): u64 {
        self.voting_period
    }  

    public fun dao_voting_quorum_rate(self: &Dao): u64 {
        self.voting_quorum_rate
    }    

    public fun min_action_delay(self: &Dao): u64 {
        self.min_action_delay
    }    

    public fun min_quorum_votes(self: &Dao): u64 {
        self.min_quorum_votes
    }  

    public fun queued_proposal(self: &mut Dao): &mut Table<ID, bool> {
        &mut self.queued_proposal
    } 

    public fun executed_proposal(self: &mut Dao): &mut Table<ID, bool> {
        &mut self.executed_proposal
    } 
}
