%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.messages import send_message_to_l1

@storage_var
func assigned_random_value() -> (res: felt) {
}

@event
func RandomValueReceived(rand_value: felt) {
}

const L1_WALLET = 0x8472A2725Ef5bC8932c2733Bb5EE4401022bbb08;
const L2_WALLET = 0x073eb291861D13Aa2584626Fb8759ACbDAD2C513A487254a993D6Fd2c6dC3Be4;

const L1_MESSAGING_NFT = 0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E;

@external
func create_l1_nft_message{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    l1_user: felt
) {
    let (message_payload: felt*) = alloc();
    assert message_payload[0] = L1_WALLET;
    send_message_to_l1(to_address=L1_MESSAGING_NFT, payload_size=1, payload=message_payload);
    return ();
}

@l1_handler
func evaluator_func{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_address: felt, rand_value: felt
) {
    assigned_random_value.write(rand_value);
    RandomValueReceived.emit(rand_value);
    return ();
}

@view
func l1_assigned_var{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let (res: felt) = assigned_random_value.read();
    return (res=res);
}
