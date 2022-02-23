######### Messaging bridge evaluator

%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero

from contracts.utils.ex00_base import (
    tderc20_address,
    distribute_points,
    ex_initializer,
    has_validated_exercise,
    validate_exercise,
    only_teacher
)
from contracts.IExerciseSolution import IExerciseSolution
from contracts.Il2nft import Il2nft
from starkware.starknet.common.syscalls import (get_contract_address, get_caller_address)
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check, uint256_eq
)
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.messages import send_message_to_l1
from contracts.token.ERC20.ITDERC20 import ITDERC20
from contracts.token.ERC20.IERC20 import IERC20

#
# Declaring storage vars
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
#

@storage_var
func has_been_paired(contract_address: felt) -> (has_been_paired: felt):
end

@storage_var
func player_exercise_solution_storage(player_address: felt) -> (contract_address: felt):
end

@storage_var
func l1_nft_address_storage() -> (l1_nft_address : felt):
end

@storage_var
func l2_nft_address_storage() -> (l2_nft_address : felt):
end

@storage_var
func l1_users_storage(player_address: felt) -> (l1_user: felt):
end

@storage_var
func user_slots_storage(account: felt) -> (user_slots_storage: felt):
end

@storage_var
func values_mapped_secret_storage(slot: felt) -> (values_mapped_secret_storage: felt):
end

@storage_var
func next_slot() -> (next_slot: felt):
end

@storage_var
func was_initialized() -> (was_initialized: felt):
end

@storage_var
func l1_dummy_token_address() -> (to_address : felt):
end

@storage_var
func has_minted_storage(account: felt) -> (l1_user: felt):
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

@view
func player_exercise_solution{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(player_address: felt) -> (contract_address: felt):
    let (contract_address) = player_exercise_solution_storage.read(player_address)
    return (contract_address)
end

######### Constructor
# This function is called when the contract is deployed
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(dummy_token_address: felt, l1_nft_address: felt, l2_nft_address: felt):
    #ex_initializer(_tderc20_address, _players_registry, _workshop_id)
    # Hard coded value for now
    l1_dummy_token_address.write(dummy_token_address)
    l1_nft_address_storage.write(l1_nft_address)
    l2_nft_address_storage.write(l2_nft_address)
    return ()
end

######### External functions
# These functions are callable by other contracts
#

@external
func ex_0_a{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(l1_user: felt, amount: felt):
    # Reading caller address
    let (sender_address) = get_caller_address()
    # Checking that the user got a slot assigned
    let (user_slot) = user_slots_storage.read(sender_address)
    let (secret_value) = values_mapped_secret_storage.read(user_slot)
    assert_not_zero(user_slot)
    # Sending the Mint message.
    let (message_payload : felt*) = alloc()
    assert message_payload[0] = l1_user
    assert message_payload[1] = amount
    assert message_payload[2] = secret_value + 32
    let (l1_contract_address) = l1_dummy_token_address.read()
    send_message_to_l1(
        to_address=l1_contract_address,
        payload_size=3,
        payload=message_payload)
    has_minted_storage.write(sender_address, l1_user)
    return()
end

@l1_handler
func ex_0_b{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(from_address : felt, l2_user: felt, l1_user: felt, secret_value: felt):
    # Checking if the user has send the message
    let (has_minted) = has_minted_storage.read(l2_user)
    assert_not_zero(has_minted)
    # Make sure the message was sent by the intended L1 contract
    let (l1_contract_address) = l1_dummy_token_address.read()
    assert from_address = l1_contract_address
    let (user_slot) = user_slots_storage.read(l2_user)
    assert_not_zero(user_slot)
    let (value) = values_mapped_secret_storage.read(user_slot)
    assert value = secret_value
    # Checking if the user has validated the exercice before
    #validate_exercise(l2_user, 0)
    # Sending points to the address specified as parameter
    #distribute_points(l2_user, 2)
    return ()
end

@external
func submit_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(messaging_address: felt):
    # Reading caller address
    let (sender_address) = get_caller_address()
    # Checking this contract was not used by another group before
    let (has_solution_been_submitted_before) = has_been_paired.read(messaging_address)
    assert has_solution_been_submitted_before = 0

    # Assigning passed ERC20 as player ERC20
    player_exercise_solution_storage.write(sender_address, messaging_address)
    has_been_paired.write(messaging_address, 1)

    # Checking if player has validated this exercise before
    #let (has_validated) = has_validated_exercise(sender_address, 0)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    #if has_validated == 0:
        # player has validated
        #validate_exercise(sender_address, 0)
        # Sending points
        # setup points
        #distribute_points(sender_address, 2)
        # Deploying contract points
        #distribute_points(sender_address, 2)

    #end

    return()
end

@external
func ex1a{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(l1_user: felt):
    alloc_locals
	# Reading caller address
	let (sender_address) = get_caller_address()
	# Retrieve exercise address
	let (submited_exercise_address) = player_exercise_solution_storage.read(sender_address)
    assert_not_zero(l1_user)
    l1_users_storage.write(sender_address, l1_user)
    IExerciseSolution.create_l1_nft_message(contract_address = submited_exercise_address, l1_user = l1_user)
    return ()
end

@l1_handler
func ex1b{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(from_address : felt, l2_user: felt, l1_user: felt):
    let (l1_nft_address) = l1_nft_address_storage.read()
    assert from_address = l1_nft_address
    let (submited_l1_user) = l1_users_storage.read(l2_user)
    assert submited_l1_user = l1_user
    # Checking if the user has validated the exercice before
    #validate_exercise(user, 1)
    # Sending points to the address specified as parameter
    #distribute_points(user, 2)
    return ()
end

@l1_handler
func ex2{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(from_address: felt, l2_user: felt):
    let (l2_nft_address) = l2_nft_address_storage.read()
    Il2nft.mint_from_l1(contract_address = l2_nft_address, l2_user = l2_user)
    # Checking if the user has validated the exercice before
    #validate_exercise(user, 1)
    # Sending points to the address specified as parameter
    #distribute_points(user, 2)
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
# Only admins can call these. You don't need to understand them to finish the exercise.
#

@external
func set_random_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(values_len: felt, values: felt*):
    #only_teacher()
    # Check if the random values were already initialized
    let (was_initialized_read) = was_initialized.read()
    assert was_initialized_read = 0
    
    # Storing passed values in the store
    set_a_random_value(values_len, values)

    # Mark that value store was initialized
    was_initialized.write(1)
    return()
end

#
# Internal functions - Administration
# Only admins can call these. You don't need to understand them to finish the exercise.
#

func set_a_random_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(values_len: felt, values: felt*):
    if values_len == 0:
        # Start with sum=0.
        return ()
    end


    set_a_random_value(values_len=values_len - 1, values=values + 1 )
    values_mapped_secret_storage.write(values_len-1, [values])

    return ()
end