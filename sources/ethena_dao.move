/// Module: dao_fund
module oxdao::ethena_dao {

    use sui::table::{Self, Table};
    use std::string::{Self, String};
    use oxdao::oxdao_nft::{OxDaoNFT};
    use sui::clock::{Self, Clock};
    use sui::dynamic_object_field as ofield;

    const EInvalidQuorumRate: u64 = 1;
    const EActionDelayTooShort: u64 = 2;
    const EEmptyHash: u64 = 3;
    const EMinQuorumVotesTooSmall: u64 = 4;

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

    public fun propose(
        dao: &mut Dao,
        _nft: &OxDaoNFT,
        c: &Clock,
        action_delay: u64,
        quorum_votes: u64,
        hash: String,
        seek_amount: u64,
        ctx: &mut TxContext    
    ): Proposal{
        assert!(action_delay >= dao.min_action_delay, EActionDelayTooShort);
        assert!(quorum_votes >= dao.min_quorum_votes, EMinQuorumVotesTooSmall);
        assert!(string::length(&hash) != 0, EEmptyHash);

        let start_time = clock::timestamp_ms(c) + dao.voting_delay;

        let proposal = Proposal {
            id: object::new(ctx),
            proposer: tx_context::sender(ctx),
            start_time,
            end_time: start_time + dao.voting_period,
            for_votes: 0,
            against_votes: 0,
            for_voters_list: vector::empty(),
            against_voters_list: vector::empty(),
            eta: 0,
            action_delay,
            quorum_votes,
            voting_quorum_rate: dao.voting_quorum_rate,
            hash,
            seek_amount,
            executable: false,
        };
        proposal
    }

    public fun add_proposal_dynamically(dao: &mut Dao, proposal: Proposal) {
        let proposal_id = object::id(&proposal);
        ofield::add(&mut dao.id, proposal_id, proposal);
    }
}
