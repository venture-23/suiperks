/// Module: dao_fund
module oxdao::ethena_dao {

    use sui::table::{Self, Table};
    use std::string::{Self, String};
    use oxdao::oxdao_nft::{OxDaoNFT};
    use sui::clock::{Self, Clock};
    use sui::dynamic_object_field as ofield;

    const STATUS_PENDING: u8 = 0;
    const STATUS_ACTIVE: u8 = 1;
    const STATUS_NOT_PASSED: u8 = 2;
    const STATUS_AGREED: u8 = 3;
    const STATUS_QUEUED: u8 = 4;
    const STATUS_EXECUTABLE: u8 = 5;
    const STATUS_FINISHED: u8 = 6;

    const EInvalidQuorumRate: u64 = 1;
    const EActionDelayTooShort: u64 = 2;
    const EEmptyHash: u64 = 3;
    const EMinQuorumVotesTooSmall: u64 = 4;
    const EAlreadyVoted: u64 = 5;
    const EProposalMustBeActive: u64 = 6;
    const ENotVoted: u64 = 7;

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

    fun get_proposal_detail(proposal_id: ID, dao: &Dao): &Proposal{
        ofield::borrow<ID, Proposal>(&dao.id, proposal_id)
    } 

    public fun proposer(proposal_id: ID, dao: &Dao): address{
        get_proposal_detail(proposal_id, dao).proposer
    }

    public fun start_time(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).start_time
    } 

    public fun end_time(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).end_time
    }     

    public fun for_votes(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).for_votes
    }   

    public fun against_votes(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).against_votes
    } 

    public fun for_voters_list(proposal_id: ID, dao: &Dao): vector<ID> {
        get_proposal_detail(proposal_id, dao).for_voters_list
    }   

    public fun against_voters_list(proposal_id: ID, dao: &Dao): vector<ID> {
        get_proposal_detail(proposal_id, dao).against_voters_list
    }  

    public fun eta(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).eta
    }   

    public fun action_delay(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).action_delay
    }

    public fun quorum_votes(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).quorum_votes
    }           

    public fun voting_quorum_rate(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).voting_quorum_rate
    }

    public fun hash(proposal_id: ID, dao: &Dao): String {
        get_proposal_detail(proposal_id, dao).hash
    } 

    public fun seek_amount(proposal_id: ID, dao: &Dao): u64 {
        get_proposal_detail(proposal_id, dao).seek_amount
    }  

    public fun executable(proposal_id: ID, dao: &Dao): bool {
        get_proposal_detail(proposal_id, dao).executable
    }

    // Voting

    fun get_mutable_proposal_detail(proposal_id: ID, dao: &mut Dao): &mut Proposal{
        ofield::borrow_mut<ID, Proposal>(&mut dao.id, proposal_id)
    } 

    public fun cast_vote(
        dao: &mut Dao,
        proposal_id: ID,
        nft: &OxDaoNFT,
        c: &Clock,
        agree: bool,
    ){
        // needs to check proposal state before casting vote
        assert!(proposal_state_impl(dao, proposal_id, clock::timestamp_ms(c)) == STATUS_ACTIVE, EProposalMustBeActive);
        let nft_id = object::id(nft);
        assert!(!vector::contains(&for_voters_list(proposal_id, dao), &nft_id), EAlreadyVoted);
        assert!(!vector::contains(&against_voters_list(proposal_id, dao), &nft_id), EAlreadyVoted);
        let proposal_data = get_mutable_proposal_detail(proposal_id, dao);
        if (agree){ 
            proposal_data.for_votes = proposal_data.for_votes + 1;
            vector::push_back(&mut proposal_data.for_voters_list, nft_id);
        } else {
            proposal_data.against_votes = proposal_data.against_votes + 1;
            vector::push_back(&mut proposal_data.against_voters_list, nft_id);
        };
    }

    public fun change_vote(
        dao: &mut Dao,
        proposal_id: ID,
        nft: &OxDaoNFT,
        c: &Clock,
    ) {
        assert!(proposal_state_impl(dao, proposal_id, clock::timestamp_ms(c)) == STATUS_ACTIVE, EProposalMustBeActive);
        let nft_id = object::id(nft);
        assert!(vector::contains(&for_voters_list(proposal_id, dao), &nft_id) || vector::contains(&against_voters_list(proposal_id, dao), &nft_id), ENotVoted);
        if (vector::contains(&against_voters_list(proposal_id, dao), &nft_id)) {
            let proposal_data = get_mutable_proposal_detail(proposal_id, dao);
            proposal_data.against_votes = proposal_data.against_votes - 1;
            proposal_data.for_votes = proposal_data.for_votes + 1;
            vector::push_back(&mut proposal_data.for_voters_list, nft_id);
        } else {
            let proposal_data = get_mutable_proposal_detail(proposal_id, dao);
            proposal_data.for_votes = proposal_data.for_votes - 1;
            proposal_data.against_votes = proposal_data.against_votes + 1;
            vector::push_back(&mut proposal_data.against_voters_list, nft_id);
        };  
    }

    public fun revoke_vote(
        dao: &mut Dao,
        proposal_id: ID,
        nft: &OxDaoNFT,
        c: &Clock,
    ){
        assert!(proposal_state_impl(dao, proposal_id, clock::timestamp_ms(c)) == STATUS_ACTIVE, EProposalMustBeActive);
        let nft_id = object::id(nft);
        assert!(vector::contains(&for_voters_list(proposal_id, dao), &nft_id) || vector::contains(&against_voters_list(proposal_id, dao), &nft_id), ENotVoted);
        if (vector::contains(&for_voters_list(proposal_id, dao), &nft_id)) {
            let proposal_data = get_mutable_proposal_detail(proposal_id, dao);
            proposal_data.for_votes = proposal_data.for_votes - 1;
            let (_, index) = vector::index_of(&proposal_data.for_voters_list, &nft_id);
            vector::remove(&mut proposal_data.for_voters_list, index);
        } else {
            let proposal_data = get_mutable_proposal_detail(proposal_id, dao);
            proposal_data.against_votes = proposal_data.against_votes - 1;
            let (_, index) = vector::index_of(&proposal_data.against_voters_list, &nft_id);
            vector::remove(&mut proposal_data.against_voters_list, index);
        };
    }

    fun proposal_state_impl(
        dao: &Dao,
        proposal_id: ID,
        current_time: u64,
    ): u8 {
        if (current_time < start_time(proposal_id, dao)) {
        STATUS_PENDING
        } else if (current_time <= end_time(proposal_id, dao)) {
        STATUS_ACTIVE
        } else if (
        for_votes(proposal_id, dao) + against_votes(proposal_id, dao) == 0 ||
        for_votes(proposal_id, dao)  <= against_votes(proposal_id, dao) ||
        for_votes(proposal_id, dao)  + against_votes(proposal_id, dao) < quorum_votes(proposal_id, dao) || 
        voting_quorum_rate(proposal_id, dao) > (for_votes(proposal_id, dao)  / for_votes(proposal_id, dao)  + against_votes(proposal_id, dao))
        ) {
        STATUS_NOT_PASSED
        } else if (eta(proposal_id, dao) == 0) {
        STATUS_AGREED
        } else if (current_time < eta(proposal_id, dao)) {
        STATUS_QUEUED
        } else if (executable(proposal_id, dao)) {
        STATUS_EXECUTABLE
        } else {
        STATUS_FINISHED
        }
    } 
}
