# ######## Messaging bridge evaluator

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero

from contracts.utils.ex00_base import (
    tuto_erc20_address,
    ex_initializer,
    has_validated_exercise,
    validate_and_distribute_points_once,
    only_teacher,
    teacher_accounts,
    assigned_rank,
    assign_rank_to_player,
    random_attributes_storage,
    max_rank_storage,
)
from contracts.IExerciseSolution import IExerciseSolution
from contracts.Il2nft import Il2nft
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_le,
    uint256_lt,
    uint256_check,
    uint256_eq,
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
func has_been_paired(contract_address : felt) -> (has_been_paired : felt):
end

@storage_var
func player_exercise_solution_storage(player_address : felt) -> (contract_address : felt):
end

@storage_var
func l1_nft_address_storage() -> (l1_nft_address : felt):
end

@storage_var
func l2_nft_address_storage() -> (l2_nft_address : felt):
end

@storage_var
func l1_users_storage(player_address : felt) -> (l1_user : felt):
end

@storage_var
func l1_dummy_token_address() -> (to_address : felt):
end

@storage_var
func l1_evaluator_address_storage() -> (l1_evaluator_address : felt):
end

@storage_var
func assigned_rand_var_storage(l2_contract : felt) -> (assigned_rand_var : felt):
end

@storage_var
func has_minted_storage(account : felt) -> (l1_user : felt):
end

#
# Declaring getters
# Public variables should be declared explicitly with a getter
#

@view
func player_exercise_solution{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_address : felt
) -> (contract_address : felt):
    let (contract_address) = player_exercise_solution_storage.read(player_address)
    return (contract_address)
end

# ######## Constructor
# This function is called when the contract is deployed
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    _tderc20_address : felt,
    _players_registry : felt,
    _workshop_id : felt,
    dummy_token_address : felt,
    l1_nft_address : felt,
    l2_nft_address : felt,
    l1_evaluator_address : felt,
    _first_teacher : felt,
):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id)
    # Hard coded value for now
    max_rank_storage.write(100)
    teacher_accounts.write(_first_teacher, 1)
    l1_dummy_token_address.write(dummy_token_address)
    l1_nft_address_storage.write(l1_nft_address)
    l2_nft_address_storage.write(l2_nft_address)
    l1_evaluator_address_storage.write(l1_evaluator_address)
    return ()
end

# ######## External functions
# These functions are callable by other contracts
#

@external
func ex_0_a{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    l1_user : felt, amount : felt
):
    alloc_locals
    # Reading caller address
    let (sender_address) = get_caller_address()
    # Checking that the user got a slot assigned
    assign_rank_to_player(sender_address)
    let (rank) = assigned_rank(sender_address)
    let (secret_value) = random_attributes_storage.read(rank, 0)
    # Sending the Mint message.
    let (message_payload : felt*) = alloc()
    assert message_payload[0] = l1_user
    assert message_payload[1] = amount
    assert message_payload[2] = secret_value + 32
    let (l1_contract_address) = l1_dummy_token_address.read()
    send_message_to_l1(to_address=l1_contract_address, payload_size=3, payload=message_payload)
    has_minted_storage.write(sender_address, l1_user)
    return ()
end

@l1_handler
func ex_0_b{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_address : felt, l2_user : felt, l1_user : felt, secret_value : felt
):
    # Checking if the user has send the message
    let (has_minted) = has_minted_storage.read(l2_user)
    with_attr error_message("User did not call ex_0_a"):
        assert_not_zero(has_minted)
    end
    # Make sure the message was sent by the intended L1 contract
    let (l1_contract_address) = l1_dummy_token_address.read()
    with_attr error_message("Message was not sent by the official L1 contract"):
        assert from_address = l1_contract_address
    end
    let (rank) = assigned_rank(l2_user)
    let (value) = random_attributes_storage.read(rank, 0)
    with_attr error_message("Wrong secret value"):
        assert value = secret_value
    end
    validate_and_distribute_points_once(l2_user, 0, 2)
    return ()
end

@external
func submit_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    solution_address : felt
):
    # Reading caller address
    let (sender_address) = get_caller_address()
    # Checking this contract was not used by another group before
    let (has_solution_been_submitted_before) = has_been_paired.read(solution_address)
    with_attr error_message("Solution already submitted"):
        assert has_solution_been_submitted_before = 0
    end
    # Assigning passed ERC20 as player ERC20
    player_exercise_solution_storage.write(sender_address, solution_address)
    has_been_paired.write(solution_address, 1)

    # Checking if player has validated this exercise before
    let (has_validated) = has_validated_exercise(sender_address, 0)
    # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...

    return ()
end

@external
func ex1a{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(l1_user : felt):
    alloc_locals
    # Reading caller address
    let (sender_address) = get_caller_address()
    # Retrieve exercise address
    let (submited_exercise_address) = player_exercise_solution_storage.read(sender_address)
    with_attr error_message("L1 user address is 0"):
        assert_not_zero(l1_user)
    end
    l1_users_storage.write(sender_address, l1_user)
    IExerciseSolution.create_l1_nft_message(
        contract_address=submited_exercise_address, l1_user=l1_user
    )
    return ()
end

@l1_handler
func ex1b{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_address : felt, l2_user : felt, l1_user : felt
):
    let (l1_nft_address) = l1_nft_address_storage.read()
    with_attr error_message("Message was not sent by the official L1 contract"):
        assert from_address = l1_nft_address
    end
    let (submited_l1_user) = l1_users_storage.read(l2_user)
    with_attr error_message("Not the same L1 user submitted on ex1a"):
        assert submited_l1_user = l1_user
    end
    validate_and_distribute_points_once(l2_user, 1, 2)
    return ()
end

@l1_handler
func ex2{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_address : felt, l2_user : felt
):
    let (l2_nft_address) = l2_nft_address_storage.read()
    Il2nft.mint_from_l1(contract_address=l2_nft_address, l2_user=l2_user)
    validate_and_distribute_points_once(l2_user, 2, 2)
    return ()
end

@external
func ex3_a{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    l1PlayerContract : felt
):
    let (sender_address) = get_caller_address()
    let (message_payload : felt*) = alloc()
    assert message_payload[0] = sender_address
    send_message_to_l1(to_address=l1PlayerContract, payload_size=1, payload=message_payload)
    return ()
end

@l1_handler
func ex3_b{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_address : felt, l2_user : felt
):
    let (l1_evaluator_address) = l1_evaluator_address_storage.read()
    with_attr error_message("Message was not sent by the official L1 contract"):
        assert from_address = l1_evaluator_address
    end
    validate_and_distribute_points_once(l2_user, 3, 2)
    return ()
end

@l1_handler
func ex4_a{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_address : felt, l2ReceiverContract : felt, rand_value : felt
):
    let (l1_evaluator_address) = l1_evaluator_address_storage.read()
    with_attr error_message("Message was not sent by the official L1 contract"):
        assert from_address = l1_evaluator_address
    end
    assigned_rand_var_storage.write(l2ReceiverContract, rand_value)
    return ()
end

@external
func ex4_b{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    let (sender_address) = get_caller_address()
    # Retrieve exercise address
    let (submited_exercise_address) = player_exercise_solution_storage.read(sender_address)
    let (assigned_var) = assigned_rand_var_storage.read(submited_exercise_address)
    with_attr error_message("No value was assigned"):
        assert_not_zero(assigned_var)
    end
    let (value) = IExerciseSolution.l1_assigned_var(contract_address=submited_exercise_address)
    with_attr error_message("assigned value and actual value don't match"):
        assert value = assigned_var
    end
    validate_and_distribute_points_once(sender_address, 4, 2)
    return ()
end
