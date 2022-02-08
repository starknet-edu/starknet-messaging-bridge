%lang starknet

from starkware.cairo.common.uint256 import Uint256


@contract_interface
namespace IExerciseSolution:
    # Example function
    func an_example(account: felt) -> (is_approved: felt):
    end
   
end