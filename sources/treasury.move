/// Module: dao_fund
module oxdao::treasury {
    use sui::bag::{Self, Bag};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use std::type_name::{Self, TypeName};
    use sui::event::emit;

    public struct DaoTreasury has key, store {
        id: UID,
        coins: Bag,
    }

    public struct DepositedCoin has copy, drop {
        value: u64,
        coin_type: TypeName,
    }

    public struct Transfer has copy, drop {
        value: u64,
        user: address
    }

    fun init(ctx:&mut TxContext) {
        transfer::share_object(DaoTreasury {
            id: object::new(ctx),
            coins: bag::new(ctx),
        });
    }
}

