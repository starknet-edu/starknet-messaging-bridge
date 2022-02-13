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
from starkware.starknet.common.syscalls import (get_contract_address, get_caller_address)
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check, uint256_eq
)
from contracts.token.ERC20.ITDERC20 import ITDERC20
from contracts.token.ERC20.IERC20 import IERC20

#
# Declaring storage vars
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
#

@storage_var
func max_rank_storage() -> (max_rank: felt):
end

@storage_var
func next_rank_storage() -> (next_rank: felt):
end

@storage_var
func random_attributes_storage(column: felt, rank: felt) -> (value: felt):
end

@storage_var
func assigned_rank_storage(player_address: felt) -> (rank: felt):
end

@storage_var
func has_been_paired(contract_address: felt) -> (has_been_paired: felt):
end

@storage_var
func player_exercise_solution_storage(player_address: felt) -> (contract_address: felt):
end

@storage_var
func l1_nft_address() -> (l1_nft_address : felt):
end

@storage_var
func l1_users_storage(player_address: felt) -> (l1_user: felt):
end

#
# Declaring getters
# Public variables should be declared explicitly with a getter
#

@view
func next_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (next_rank: felt):
    let (next_rank) = next_rank_storage.read()
    return (next_rank)
end

@view
func player_exercise_solution{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(player_address: felt) -> (contract_address: felt):
    let (contract_address) = player_exercise_solution_storage.read(player_address)
    return (contract_address)
end

@view
func assigned_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(player_address: felt) -> (rank: felt):
    let (rank) = assigned_rank_storage.read(player_address)
    return (rank)
end


######### Constructor
# This function is called when the contract is deployed
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    _tderc20_address : felt, 
        _players_registry: felt, 
        _workshop_id: felt):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id)
    # Hard coded value for now
    max_rank_storage.write(100)
    return ()
end

######### External functions
# These functions are callable by other contracts
#

@external
func submit_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(messaging_address: felt):
    # Reading caller address
    let (sender_address) = get_caller_address()
    # Checking this contract was not used by another group before
    let (has_solution_been_submitted_before) = has_been_paired.read(messaging_address)
    assert has_solution_been_submitted_before = 0

    # Assigning passed ERC20 as player ERC20
    player_exercise_solution_storage.write(sender_address, messaging_address)
    has_been_paired.write(erc20_address, 1)

    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(sender_address, 0)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    if has_validated == 0:
        # player has validated
        validate_exercise(sender_address, 0)
        # Sending points
        # setup points
        #distribute_points(sender_address, 2)
        # Deploying contract points
        #distribute_points(sender_address, 2)

    end

    return()
end

@external
func create_l1_nft{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(l1_user: felt):
    alloc_locals
	# Reading caller address
	let (sender_address) = get_caller_address()
	# Retrieve exercise address
	let (submited_exercise_address) = player_exercise_solution_storage.read(sender_address)
    assert_not_zero(l1_user)
    l1_users_storage.write(sender_address, l1_user)
    IExerciseSolution.create_l1_nft_message(contract_address = submited_exercise_address, l1_user = l1_user)
end

@l1_handler
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(from_address : felt, l2_user: felt, l1_user: felt):
    let (l1_nft_address) = l1_nft_address.read()
    assert from_address = l1_nft_address
    let (submited_l1_user) = l1_users_storage.read(l2_user)
    assert submited_l1_user = l1_user
    # Checking if the user has validated the exercice before
    validate_exercise(user, 1)
    # Sending points to the address specified as parameter
    distribute_points(user, 2)
    return ()
end

#
# Internal functions
#

func assign_rank_to_player{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(sender_address:felt):
    alloc_locals

    # Reading next available slot
    let (next_rank) = next_rank_storage.read()
    # Assigning to user
    assigned_rank_storage.write(sender_address, next_rank)

    let new_next_rank = next_rank + 1
    let (max_rank) = max_rank_storage.read()

    # Checking if we reach max_rank
    if new_next_rank == max_rank:
        next_rank_storage.write(0)
    else:
        next_rank_storage.write(new_next_rank)
    end
    return()
end

#
# External functions - Administration
# Only admins can call these. You don't need to understand them to finish the exercise.
#

@external
func set_random_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(values_len: felt, values: felt*, column: felt):
    only_teacher()
    # Check that we fill max_ranK_storage cells
    let (max_rank) = max_rank_storage.read()
    assert values_len = max_rank
    # Storing passed values in the store
    set_a_random_value(values_len, values, column)
    return()
end

#
# Internal functions - Administration
# Only admins can call these. You don't need to understand them to finish the exercise.
#

func set_a_random_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(values_len: felt, values: felt*, column: felt):
    if values_len == 0:
        # Start with sum=0.
        return ()
    end


    set_a_random_value(values_len=values_len - 1, values=values + 1, column=column)
    random_attributes_storage.write(column, values_len-1, [values])

    return ()
end
