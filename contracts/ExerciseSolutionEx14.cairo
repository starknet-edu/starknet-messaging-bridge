// Deployed address and points here -> 0x007cb4fc6d47050d0255f23ecdc14ce9fe8fd3ad96b71c6fc1bf243e9d078b14

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

const tderc20_address = 0x5c6b1379f1d4c8a4f5db781a706b63a885f3f9570f7863629e99e2342ac344c;
const OWNER = 0x73eb291861D13Aa2584626Fb8759ACbDAD2C513A487254a993D6Fd2c6dC3Be4;

const GENERAL_SYNTAX_EX = 0x29e2801df18d7333da856467c79aa3eb305724db57f386e3456f85d66cbd58b;
@contract_interface
namespace IGeneralSyntax {
    func claim_points() {
    }
}

const STORAGE_VARIABLES_GETTERS_ASSERTS_EX = 0x18ef3fa8b5938a0059fa35ee6a04e314281a3e64724fe094c80e3720931f83f;
@contract_interface
namespace IStorageVariablesGettersAsserts {
    func my_secret_value() -> (my_secret_value: felt) {
    }

    func claim_points(my_value: felt) {
    }
}

@contract_interface
namespace IAllInOneContract {
    func validate_various_exercises() {
    }
}

@contract_interface
namespace IERC20 {
    func balanceOf(account: felt) -> (balance: Uint256) {
    }

    func transfer(recipient: felt, amount: Uint256) -> (success: felt) {
    }
}

const EX_14 = 0x00ed7ddffe1370fbbc1974ab8122d1d9bd7e3da8d829ead9177ea4249b4caef1;

@contract_interface
namespace IEx14 {
    func claim_points() {
    }
}

@external
func claim_on_exercise{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    IEx14.claim_points(EX_14);
    return ();
}

@external
func validate_various_exercises{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (caller: felt) = get_caller_address();
    assert caller = EX_14;
    IGeneralSyntax.claim_points(GENERAL_SYNTAX_EX);
    let (my_secret_value: felt) = IStorageVariablesGettersAsserts.my_secret_value(
        STORAGE_VARIABLES_GETTERS_ASSERTS_EX
    );
    IStorageVariablesGettersAsserts.claim_points(
        STORAGE_VARIABLES_GETTERS_ASSERTS_EX, my_secret_value
    );
    return ();
}

@external
func collect_coins{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (caller: felt) = get_caller_address();
    assert caller = OWNER;
    let (this: felt) = get_contract_address();
    let (balance: Uint256) = IERC20.balanceOf(tderc20_address, this);
    IERC20.transfer(tderc20_address, OWNER, balance);
    return ();
}
