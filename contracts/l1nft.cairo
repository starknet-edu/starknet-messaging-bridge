%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import (get_contract_address, get_caller_address)
from starkware.cairo.common.uint256 import (Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check, uint256_eq)
from contracts.token.ERC721.ERC721_base import (
    ERC721_name,
    ERC721_symbol,
    ERC721_balanceOf,
    ERC721_ownerOf,
    ERC721_getApproved,
    ERC721_isApprovedForAll,
    ERC721_mint,
    ERC721_burn,

    ERC721_initializer,
    ERC721_approve,
    ERC721_setApprovalForAll,
    ERC721_transferFrom,
    ERC721_safeTransferFrom
)

@storage_var
func next_token_id_storage() -> (next_token_id: Uint256):
end

#
# Constructor
#

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(name: felt, symbol: felt):
    ERC721_initializer(name, symbol)
    let token_id : Uint256 = Uint256(1,0)
    next_token_id_storage.write(token_id)
    return ()
end

@l1_handler
func mint_from_l1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(from_address : felt, l2_user: felt):
    let token_id : Uint256 = next_token_id_storage.read()
    let one_as_uint256: Uint256 = Uint256(1,0)
    ERC721_mint(l2_user, token_id)
    let next_token_id : Uint256  = uint256_add(token_id, one_as_uint256)
    next_token_id_storage.write(next_token_id)
end



