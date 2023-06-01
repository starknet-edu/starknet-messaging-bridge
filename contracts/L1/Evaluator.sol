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
    uint256 public ex02_b_selector;
    uint256 public ex04_b_selector;
    uint256 public ex06_b_selector;


    event HashCalculated(bytes32 msgHash_);
    event MessageReceived(uint256 msgInDecimal);

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
        uint256[] memory payload = new uint256[](3);
        // Adding player address on L2
        payload[0] = player_l2_address;
        // Adding player address on L1 
        payload[1] = uint256(uint160(msg.sender));
        // Adding player message 
        payload[2] = message;
        starknetCore.sendMessageToL2(l2Evaluator, ex01_selector, payload);
    }

    function ex02ReceiveMessageFromL2(uint256 player_l2_address, uint256 message) external {
        // Receiving a message from L2
        // Reconstructing the payload of the message we want to consume
        uint256[] memory payload = new uint256[](2);
        // Adding the address of the player on L2
        payload[0] = player_l2_address;
        // Adding the message
        payload[2] = message;

        // Consuming the message
        // If the message constructed above was indeed sent by starknet, this returns the hash of the message
        // If the message was NOT sent by starknet, the cal will revert 
        starknetCore.consumeMessageFromL2(l2Evaluator, payload);
        // Firing an event, for fun
        emit MessageReceived(message);
        // Crediting points to the player, on L2
        // We send back a message to L2!
        // Creating the payload
        uint256[] memory payload2 = new uint256[](1);
        // Adding player address on L2
        payload2[0] = player_l2_address;
        starknetCore.sendMessageToL2(l2Evaluator, ex02_b_selector, payload2);
    }

    function ex04ReceiveMessageFromAnL2Contract(uint256 player_l2_address, uint256 message) external {
        // Receiving a message from an L2 contract
        // To collect points, you need to deploy an L2 contract that uses send_message_to_l1_syscall() correctly.
        // The L2 evaluator will credit point if and only if it receives a properly formatted message with:
        // - The L2 player address, to whom points will be credited
        // - The L1 address that will trigger this function
        // - A message

        // Reconstructing the payload of the message we want to consume
        uint256[] memory payload = new uint256[](3);
        // Adding the address of the player on L2
        payload[0] = player_l2_address;
        // Adding the address of the player on L1
        payload[1] = uint256(uint160(msg.sender));
        // Adding the message
        payload[2] = message;
        // Consuming the message
        // If the message constructed above was indeed sent by starknet, this returns the hash of the message
        // If the message was NOT sent by starknet, the cal will revert 
        starknetCore.consumeMessageFromL2(l2Evaluator, payload);
        // Crediting points to the player, on L2
        // We send back a message to L2!
        // Creating the payload
        uint256[] memory payload2 = new uint256[](1);
        // Adding player address on L2
        payload2[0] = player_l2_address;
        starknetCore.sendMessageToL2(l2Evaluator, ex04_b_selector, payload2);

    }

    function ex05SendMessageToAnL2CustomContract() external {
        // Sending a message to a custom L2 contract
        // To collect points, you need to deploy an L2 contract that includes an l1 handler that can receive messages from L1.

        // Reconstructing the payload of the message we want to consume
        uint256[] memory payload = new uint256[](3);
        // Adding the address of the player on L2
        payload[0] = player_l2_address;
        // Adding the address of the player on L1
        payload[1] = uint256(uint160(msg.sender));
        // Adding the message
        payload[2] = message;
        // Consuming the message
        // If the message constructed above was indeed sent by starknet, this returns the hash of the message
        // If the message was NOT sent by starknet, the cal will revert 
        starknetCore.consumeMessageFromL2(l2Evaluator, payload);
        // Crediting points to the player, on L2
        // We send back a message to L2!
        // Creating the payload
        uint256[] memory payload2 = new uint256[](1);
        // Adding player address on L2
        payload2[0] = player_l2_address;
        starknetCore.sendMessageToL2(l2Evaluator, ex04_b_selector, payload2);

    }

    function ex06ReceiveMessageFromAnL2CustomContract(address playerMessageReceiver, uint256 player_l2_address) external {
        // Receiving a message to a custom L2 contract
        // To collect points, you need to deploy an L1 contract that is able to consume a message from L2
        // Step by step:
        // - Deploy an L1 contract that can consume messages from L2. 
        //      - Message consumption should happen in a function called consumeMessage(), callable by anyone
        // - Use the L2 evaluator to send a message to you L1 contract  
        // - Wait for the message to arrive on Ethereum
        // - Call this function ex05ReceiveMessageFromAnL2CustomContract to trigger the message consumption on your contract
        // - Points are sent back to your account contract on L2

        // Connecting to the player's L1 contract        
        ISolution playerSolution = ISolution(playerMessageReceiver);
        // Calculating the message Hash
        uint256[] memory payload = new uint256[](1);
        payload[0] = player_l2_address;
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                l2Evaluator, // Who sent the message
                uint256(uint160(playerMessageReceiver)), // To whom was it sent
                payload.length, // Data length
                payload // Data
            )
        );
        // Checking if the the message reached Ethereum
        uint256 isMessagePresent = starknetCore.l2ToL1Messages(msgHash);
        require(isMessagePresent > 0, "The message is not present on the proxy");
        // Calling player's L1 contract to consume the message
        playerSolution.consumeMessage(l2Evaluator, player_l2_address);
        // Checking if the the message was consumed
        uint256 wasMessageConsumed = starknetCore.l2ToL1Messages(msgHash);
        require(
            wasMessageConsumed == (isMessagePresent - 1),
            "The message was  not consumed"
        );
        // Crediting points on L2
        // Building the payload
        uint256[] memory payload2 = new uint256[](1);
        // Adding player address on L2
        payload2[0] = player_l2_address;
        // Sending the message
        starknetCore.sendMessageToL2(l2Evaluator, ex06_b_selector, payload2);
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
    function setEx02BSelector(uint256 ex02_b_selector_) external onlyOwner {
        ex02_b_selector = ex02_b_selector_;
    }
    function setEx04BSelector(uint256 ex04_b_selector_) external onlyOwner {
        ex04_b_selector = ex04_b_selector_;
    }
    function setEx06BSelector(uint256 ex06_b_selector_) external onlyOwner {
        ex06_b_selector = ex06_b_selector_;
    }

}
