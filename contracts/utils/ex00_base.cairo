######### Ex 00
## A contract from which other contracts can import functions

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check
)
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import (get_contract_address, get_caller_address)

from contracts.token.ERC20.IERC20 import IERC20
from contracts.token.ERC20.ITDERC20 import ITDERC20
from contracts.utils.Iplayers_registry import Iplayers_registry

#
# Declaring storage vars
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
#

@storage_var
func tuto_erc20_address_storage() -> (tuto_erc20_address_address : felt):
end

@storage_var
func players_registry_storage() -> (players_registry_address : felt):
end

@storage_var
func workshop_id_storage() -> (workshop_id : felt):
end

@storage_var
func teacher_accounts(account : felt) -> (balance : felt):
end

@storage_var
func max_rank_storage() -> (max_rank : felt):
end

@storage_var
func next_rank_storage() -> (next_rank : felt):
end

@storage_var
func random_attributes_storage(rank : felt, column : felt) -> (value : felt):
end

@storage_var
func assigned_rank_storage(player_address : felt) -> (rank : felt):
end

#
# Declaring getters
# Public variables should be declared explicitly with a getter
#

@view
func tuto_erc20_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_tuto_erc20_address : felt):
    let (_tuto_erc20_address) = tuto_erc20_address_storage.read()
    return (_tuto_erc20_address)
end

@view
func players_registry{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_players_registry : felt):
    let (_players_registry) = players_registry_storage.read()
    return (_players_registry)
end

@view
func has_validated_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account : felt, exercise_id : felt) -> (has_validated_exercise : felt):
    # reading player registry
    let (_players_registry) = players_registry_storage.read()
    let (_workshop_id) = workshop_id_storage.read()
    # Checking if the user already validated this exercise
    let (has_current_user_validated_exercise) = Iplayers_registry.has_validated_exercise(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = exercise_id)
    return (has_current_user_validated_exercise)
end


@view
func next_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (next_rank : felt):
    let (next_rank) = next_rank_storage.read()
    return (next_rank)
end

@view
func assigned_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        player_address : felt) -> (rank : felt):
    let (rank) = assigned_rank_storage.read(player_address)
    return (rank)
end

#
# Internal constructor
# This function is used to initialize the contract. It can be called from the constructor
#

func ex_initializer{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        _tuto_erc20_address : felt,
        _players_registry : felt,
        _workshop_id : felt
    ):
    tuto_erc20_address_storage.write(_tuto_erc20_address)
    players_registry_storage.write(_players_registry)
    workshop_id_storage.write(_workshop_id)
    return ()
end

#
# Internal functions
# These functions can not be called directly by a transaction
# Similar to internal functions in Solidity
#

func distribute_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(to : felt, amount : felt):
    # Converting felt to uint256. We assume it's a small number
    # We also add the required number of decimals
    let points_to_credit : Uint256 = Uint256(amount*1000000000000000000, 0)
    # Retrieving contract address from storage
    let (contract_address) = tuto_erc20_address_storage.read()
    # Calling the ERC20 contract to distribute points
    ITDERC20.distribute_points(contract_address=contract_address, to = to, amount = points_to_credit)
    return()
end

func validate_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account : felt, exercise_id):
    # reading player registry
    let (_players_registry) = players_registry_storage.read()
    let (_workshop_id) = workshop_id_storage.read()
    # Checking if the user already validated this exercise
    let (has_current_user_validated_exercise) = Iplayers_registry.has_validated_exercise(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = exercise_id)
    assert (has_current_user_validated_exercise) = 0

    # Marking the exercise as completed
    Iplayers_registry.validate_exercise(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = exercise_id)

    return()
end

func validate_and_distribute_points_once{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        sender_address : felt,
        exercise : felt,
        points : felt):

    # Checking if player has validated this exercise before
    let(has_validated) = has_validated_exercise(sender_address, exercise)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    if has_validated == 0:
        # player has validated
        validate_exercise(sender_address, exercise)
        # Sending Setup, contract & deployment points
        distribute_points(sender_address, points)
    end
    return()
end



func only_teacher{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    let (caller) = get_caller_address()
    let (permission) = teacher_accounts.read(account=caller)
    assert permission = 1
    return ()
end

@external
func set_teacher{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account : felt, permission : felt):
    only_teacher()
    teacher_accounts.write(account, permission)

    return ()
end

@view
func is_teacher{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account : felt) -> (permission : felt):
    let (permission : felt) = teacher_accounts.read(account)
    return (permission)
end


#
# External functions - Administration
# Only admins can call these. You don't need to understand them to finish the exercise.
#

@external
func set_random_values{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(values_len : felt, values : felt*, column : felt):
    only_teacher()
    # Check that we fill max_ranK_storage cells
    let (max_rank) = max_rank_storage.read()
    assert values_len = max_rank
    # Storing passed values in the store
    set_a_random_value(values_len, values, column)
    return ()
end

#
# Internal functions - Administration
# Only admins can call these. You don't need to understand them to finish the exercise.
#

func set_a_random_value{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(values_len : felt, values : felt*, column : felt):
    if values_len == 0:
        # Start with sum=0.
        return ()
    end
    set_a_random_value(values_len=values_len - 1, values=values + 1, column=column)
    random_attributes_storage.write(values_len - 1, column, [values])
    return ()
end

func assign_rank_to_player{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        sender_address : felt):
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
    return ()
end