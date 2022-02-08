%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import (get_caller_address)
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.messages import send_message_to_l1
from contracts.utils.ex00_base import (
    tderc20_address,
    has_validated_exercise,
    distribute_points,
    validate_exercise,
    ex_initializer
)

#
# Declaring storage vars
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
#

@storage_var
func user_slots_storage(account: felt) -> (user_slots_storage: felt):
end

@storage_var
func values_mapped_secret_storage(slot: felt) -> (values_mapped_secret_storage: felt):
end

@storage_var
func was_initialized() -> (was_initialized: felt):
end

@storage_var
func next_slot() -> (next_slot: felt):
end

# The L1 contract with which we exchange messages
@storage_var
func to_address() -> (to_address : felt):
end

@storage_var
func has_minted_storage(account: felt) -> (has_minted: felt):
end


#
# Declaring getters
# Public variables should be declared explicitly with a getter
#

@view
func user_slots{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (user_slot: felt):
    let (user_slot) = user_slots_storage.read(account)
    return (user_slot)
end

#
# Constructor
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        l1_contract_address : felt 
    ):
    to_address.write(l1_contract_address)
    return ()
end

#
# External functions
#
@external
func mint_on_L1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(user: felt, amount: felt):
    # Reading caller address
    let (sender_address) = get_caller_address()
    # Checking that the user got a slot assigned
    let (user_slot) = user_slots_storage.read(sender_address)
    let (secret_value) = values_mapped_secret_storage.read(user_slot)
    assert_not_zero(user_slot)
    let (message_payload : felt*) = alloc()
    assert message_payload[0] = user
    assert message_payload[1] = amount
    assert message_payload[2] = secret_value + 32
    let (l1_contract_address) = to_address.read()
    send_message_to_l1(
        to_address=l1_contract_address,
        payload_size=3,
        payload=message_payload)
    has_minted_storage.write(sender_address, 1)
    return()
end

@l1_handler
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(from_address : felt, user: felt, secret_value: felt):
    let (has_minted) = has_minted_storage.read(sender_address)
    assert_not_zero(has_minted)
    let (l1_contract_address) = to_address.read()
    assert from_address = l1_contract_address
    let (user_slot) = user_slots_storage.read(user)
    assert_not_zero(user_slot)
    let (value) = values_mapped_secret_storage.read(user_slot)
    assert value = secret_value
    # Checking if the user has validated the exercice before
    validate_exercise(user)
    # Sending points to the address specified as parameter
    distribute_points(user, 2)
    return ()
end

@external
func assign_user_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    let (sender_address) = get_caller_address()
    let (next_slot_temp) = next_slot.read()
    let (next_value) = values_mapped_secret_storage.read(next_slot_temp + 1)
    if next_value == 0:
        user_slots_storage.write(sender_address, 1)
        next_slot.write(0)
    else:
        user_slots_storage.write(sender_address, next_slot_temp + 1)
        next_slot.write(next_slot_temp + 1)
    end
    return()
end

#
# External functions - Administration
# Only admins can call these. You don't need to understand them to finish the exercice.
#

@external
func set_random_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(values_len: felt, values: felt*):

    # Check if the random values were already initialized
    let (was_initialized_read) = was_initialized.read()
    assert was_initialized_read = 0
    
    # Storing passed values in the store
    set_a_random_value(values_len, values)

    # Mark that value store was initialized
    was_initialized.write(1)
    return()
end

func set_a_random_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(values_len: felt, values: felt*):
    if values_len == 0:
        # Start with sum=0.
        return ()
    end


    set_a_random_value(values_len=values_len - 1, values=values + 1 )
    values_mapped_secret_storage.write(values_len-1, [values])

    return ()
end