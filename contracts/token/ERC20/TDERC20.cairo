%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc20.library import ERC20

@storage_var
func teachers_and_exercises_accounts(account : felt) -> (balance : felt):
end

@storage_var
func is_transferable_storage() -> (is_transferable_storage : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    name : felt, symbol : felt, initial_supply : Uint256, recipient : felt, owner : felt
):
    ERC20.initializer(name, symbol, 18)
    ERC20._mint(recipient, initial_supply)
    teachers_and_exercises_accounts.write(owner, 1)
    return ()
end

#
# Getters
#

@view
func is_transferable{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    is_transferable : felt
):
    let (is_transferable) = is_transferable_storage.read()
    return (is_transferable)
end

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC20.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end

@view
func totalSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    totalSupply : Uint256
):
    let (totalSupply : Uint256) = ERC20.total_supply()
    return (totalSupply)
end

@view
func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    decimals : felt
):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (balance : Uint256):
    let (balance : Uint256) = ERC20.balance_of(account)
    return (balance)
end

@view
func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt
) -> (remaining : Uint256):
    let (remaining : Uint256) = ERC20.allowance(owner, spender)
    return (remaining)
end

#
# Externals
#

@external
func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    recipient : felt, amount : Uint256
) -> (success : felt):
    _is_transferable()
    ERC20.transfer(recipient, amount)
    # Cairo equivalent to 'return (true)'
    return (1)
end

@external
func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : Uint256
) -> (success : felt):
    _is_transferable()
    ERC20.transfer_from(sender, recipient, amount)
    # Cairo equivalent to 'return (true)'
    return (1)
end

@external
func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> (success : felt):
    ERC20.approve(spender, amount)
    # Cairo equivalent to 'return (true)'
    return (1)
end

@external
func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, added_value : Uint256
) -> (success : felt):
    ERC20.increase_allowance(spender, added_value)
    # Cairo equivalent to 'return (true)'
    return (1)
end

@external
func decreaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, subtracted_value : Uint256
) -> (success : felt):
    ERC20.decrease_allowance(spender, subtracted_value)
    # Cairo equivalent to 'return (true)'
    return (1)
end

@external
func distribute_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    to : felt, amount : Uint256
):
    only_teacher_or_exercise()
    ERC20._mint(to, amount)
    return ()
end

@external
func remove_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    to : felt, amount : Uint256
):
    only_teacher_or_exercise()
    ERC20._burn(to, amount)
    return ()
end

@external
func set_teacher{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt, permission : felt
):
    only_teacher_or_exercise()
    teachers_and_exercises_accounts.write(account, permission)

    return ()
end

@external
func set_teachers{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    accounts_len : felt, accounts : felt*
):
    only_teacher_or_exercise()
    _set_teacher(accounts_len, accounts)
    return ()
end

@external
func set_transferable{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    permission : felt
):
    only_teacher_or_exercise()
    _set_transferable(permission)
    return ()
end

@view
func is_teacher_or_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (permission : felt):
    let (permission : felt) = teachers_and_exercises_accounts.read(account)
    return (permission)
end

func _set_teacher{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    accounts_len : felt, accounts : felt*
):
    if accounts_len == 0:
        # Start with sum=0.
        return ()
    end

    # If length is NOT zero, then the function calls itself again, by moving forward one slot
    _set_teacher(accounts_len=accounts_len - 1, accounts=accounts + 1)

    # This part of the function is first reached when length=0.
    teachers_and_exercises_accounts.write([accounts], 1)
    return ()
end

func only_teacher_or_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (permission) = teachers_and_exercises_accounts.read(account=caller)
    assert permission = 1
    return ()
end

func _is_transferable{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (permission) = is_transferable_storage.read()
    assert permission = 1
    return ()
end

func _set_transferable{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    permission : felt
):
    is_transferable_storage.write(permission)
    return ()
end
