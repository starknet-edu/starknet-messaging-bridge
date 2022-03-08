%lang starknet

from starkware.cairo.common.uint256 import Uint256


@contract_interface
namespace IExerciseSolution:
    # Example function
    func create_l1_nft_message(l1_user: felt):
    end

    func l1_assigned_var() -> (assigned_var: felt):
    end
   
end