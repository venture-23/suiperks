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

    public struct DaoTreasuryEvent has copy, store, drop {
        total_amount: u64,
    }

    fun init(ctx:&mut TxContext) {
        transfer::share_object(DaoTreasury {
            id: object::new(ctx),
            coins: bag::new(ctx),
        });
    }

    // @dev function will be called after nft is sold from the auction
    
    // @todo for testing depositing the coin so removing the friend function 
    //
    public(package) fun deposite_coin_from_auction<T>(treasury: &mut DaoTreasury, token: Coin<T>) {
        let key = type_name::get<T>();
        let value = coin::value(&token);

        if (!bag::contains(&treasury.coins, key)) {
        bag::add(&mut treasury.coins, key, coin::into_balance(token))
        } else {
        balance::join(bag::borrow_mut<TypeName, Balance<T>>(&mut treasury.coins, key), coin::into_balance(token));
        };
        let present_value = balance::value(bag::borrow_mut<TypeName, Balance<T>>(&mut treasury.coins, key)) + value;
        emit(DaoTreasuryEvent{
           total_amount: present_value 
        });
        emit(DepositedCoin{ value, coin_type: key});
    }

    public fun get_total_treasury_balance<T>(treasury: &mut DaoTreasury): u64 {
        let key = type_name::get<T>(); 
        let present_value = balance::value(bag::borrow_mut<TypeName, Balance<T>>(&mut treasury.coins, key)); 
        present_value 
    }

    // @dev function will only be called if dao members pass the proposal of the intended user
    public(package) fun transfer<T>(
    treasury: &mut DaoTreasury,
    value: u64,
    user: address,
    ctx: &mut TxContext
    ): Coin<T> {
    
        let token = coin::take(bag::borrow_mut(&mut treasury.coins, type_name::get<T>()), value, ctx);

        emit(Transfer{ 
            value: value, 
            user 
        }
        );

        token
    }
}

