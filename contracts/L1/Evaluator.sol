// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ISolution.sol";
import "./interfaces/IStarknetCore.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Evaluator is Ownable {
    IStarknetCore private starknetCore;
    uint256 private l2Evaluator;
    uint256 private ex3_b_selector;
    uint256 private ex4_a_selector;
    event HashCalculated(bytes32 msgHash_);

    constructor(address starknetCore_) {
        starknetCore = IStarknetCore(starknetCore_);
    }

    function setL2Evaluator(uint256 l2Evaluator_) external onlyOwner {
        l2Evaluator = l2Evaluator_;
    }

    function setEx3BSelector(uint256 ex3_b_selector_) external onlyOwner {
        ex3_b_selector = ex3_b_selector_;
    }

    function setEx4ASelector(uint256 ex4_a_selector_) external onlyOwner {
        ex4_a_selector = ex4_a_selector_;
    }

    function ex3(uint256 l2User, address playerContract) external {
        ISolution playerSolution = ISolution(playerContract);

        //Triger sending message from L2 (Send message to L2 evaluator)
        //Calcluate message Hash
        uint256[] memory payload = new uint256[](1);
        payload[0] = l2User;
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                l2Evaluator,
                uint256(uint160(playerContract)),
                payload.length,
                payload
            )
        );
        emit HashCalculated(msgHash);
        //Check if the the message is on the proxy
        uint256 consumed = starknetCore.l2ToL1Messages(msgHash);
        require(consumed > 0, "The message is not present on the proxy");
        playerSolution.consumeMessage(l2Evaluator, l2User);
        uint256 after_consumed = starknetCore.l2ToL1Messages(msgHash);
        require(
            after_consumed == (consumed - 1),
            "The message is not consumed yet !"
        );
        starknetCore.sendMessageToL2(l2Evaluator, ex3_b_selector, payload);
    }

    function ex4(uint256 l2ReceiverContract, uint256 solution_selector)
        external
    {
        uint256 rand_value = uint160(
            uint256(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            )
        );
        uint256[] memory payload = new uint256[](2);
        payload[0] = l2ReceiverContract;
        payload[1] = rand_value;
        uint256[] memory payload_receiver = new uint256[](1);
        payload_receiver[0] = rand_value;
        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(l2Evaluator, ex4_a_selector, payload);
        starknetCore.sendMessageToL2(
            l2ReceiverContract,
            solution_selector,
            payload_receiver
        );
    }
}
