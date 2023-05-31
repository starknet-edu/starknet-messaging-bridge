// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ISolution.sol";
import "./interfaces/IStarknetCore.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Evaluator is Ownable {
    
    ////////////////////////////////
    // Storage
    ////////////////////////////////
    IStarknetCore private starknetCore;
    uint256 public l2Evaluator;
    uint256 public ex01_selector;

    event HashCalculated(bytes32 msgHash_);

    ////////////////////////////////
    // Constructor
    ////////////////////////////////

    constructor(address starknetCore_) {
        starknetCore = IStarknetCore(starknetCore_);
    }

    ////////////////////////////////
    // External Functions
    ////////////////////////////////

    function ex01SendMessageToL2(uint256 player_l2_address, uint256 message) external {
        // Sending a message to L2
        // Creating the payload
        uint256[] memory payload = new uint256[](1);
        // Adding player address on L2
        payload[0] = player_l2_address;
        // Adding player address on L1 
        payload[1] = msg.sender;
        // Adding player message 
        payload[2] = message;
        starknetCore.sendMessageToL2(l2Evaluator, ex01_selector, payload);
    }

    function ex02ReceiveMessageFromL2(uint256 player_l2_address, uint256 message) external {
        // Receiving a message from L2
        // Reconstructing the payload of the message we want to consume
        uint256[] memory payload = new uint256[](1);
        // Adding the address of the player on L2
        payload[0] = player_l2_address;
        // Adding the address of the player on L1
        payload[1] = msg.sender;
        // Adding the message
        payload[2] = message;
        // Consuming the message
        // If the message constructed above was indeed sent by starknet, this returns the hash of the message
        // If the message was NOT sent by starknet, the cal will revert 
        bytes32 messageHash = playerSolution.consumeMessage(l2Evaluator, payload);
    }


    ////////////////////////////////
    // External functions - Administration
    // Only admins can call these. You don't need to understand them to finish the exercise.
    ////////////////////////////////

    function setL2Evaluator(uint256 l2Evaluator_) external onlyOwner {
        l2Evaluator = l2Evaluator_;
    }
    function setEx01Selector(uint256 ex01_selector_) external onlyOwner {
        ex01_selector = ex01_selector_;
    }
    

}
