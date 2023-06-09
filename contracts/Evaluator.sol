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
    uint256 public genericValidatorSelector;
    uint256 public ex05b_selector;

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
        // To validate this exercice, you need to successfully call this function on L1
        // It will then send a message to the evaluator on L2, which will credit you points.
        // Be careful! There is a constraint on the value of "message". Check out the L2 evaluator to find out which...

        // Sending the message to the evaluator
        // Creating the payload
        uint256[] memory payload = new uint256[](3);
        // Adding player address on L2
        payload[0] = player_l2_address;
        // Adding player address on L1 
        payload[1] = uint256(uint160(msg.sender));
        // Adding player message 
        payload[2] = message;
        // Sending the message
        starknetCore.sendMessageToL2(l2Evaluator, ex01_selector, payload);
    }

    function ex02ReceiveMessageFromL2(uint256 player_l2_address, uint256 message) external {
        // Receiving a message from L2
        // To validate this exercice, you need to:
        // - Use the evaluator on L2 to send a message to this contract on L1
        // - Call this function on L1 to consume the message 
        // - This function will then send back a message to L2 to credit points on player_l2_address

        // Consuming the message 
        // Reconstructing the payload of the message we want to consume
        uint256[] memory payload = new uint256[](2);
        // Adding the address of the player on L2
        payload[0] = player_l2_address;
        // Adding the message
        payload[1] = message;
        // Adding a constraint on the message, to make sure players read BOTH contracts ;-)
        require(message>3121906, 'Message too small');
        require(message<4230938, 'Message too big');

        // If the message constructed above was indeed sent by starknet, this returns the hash of the message
        // If the message was NOT sent by starknet, the cal will revert 
        starknetCore.consumeMessageFromL2(l2Evaluator, payload);
       
        // Firing an event, for fun
        emit MessageReceived(message);

        // Crediting points to the player, on L2
        // Creating the payload
        uint256[] memory payload2 = new uint256[](2);
        // Adding player address on L2
        payload2[0] = player_l2_address;
        // Adding exercice number
        payload2[1] = 2;
        // Sending the message
        starknetCore.sendMessageToL2(l2Evaluator, genericValidatorSelector, payload2);
    }

    function ex04ReceiveMessageFromAnL2Contract(uint256 player_l2_address, uint256 player_l2_contract) external {
        // Receiving a message from an L2 contract
        // To collect points, you need to deploy an L2 contract that uses send_message_to_l1_syscall() correctly.
        // To validate this exercice, you need to:
        // - Deploy an L2 contract (address player_l2_contract) that uses send_message_to_l1_syscall()
        // - Use that L2 contract to send a message to this contract on L1
        // - Call this function on L1 to consume the message. Be careful, the address from which you trigger this function matters!
        // - This function will then send back a message to L2 to credit points on player_l2_address

        // Consuming the message
        // Reconstructing the payload of the message we want to consume
        uint256[] memory payload = new uint256[](2);
        // Adding the address of the player account on L2
        payload[0] = player_l2_address;
        // Adding the address of the player on L1. This means the L1->L2 message needs to specify
        // which EOA is going to trigger this function
        payload[1] = uint256(uint160(msg.sender));
        // If the message constructed above was indeed sent by starknet, this returns the hash of the message
        // If the message was NOT sent by starknet, the cal will revert 
        starknetCore.consumeMessageFromL2(player_l2_contract, payload);
        
        // Crediting points to the player, on L2
        // Creating the payload
        uint256[] memory payload2 = new uint256[](2);
        // Adding player address on L2
        payload2[0] = player_l2_address;
        // Adding exercice number
        payload2[1] = 4;
        // Sending the message
        starknetCore.sendMessageToL2(l2Evaluator, genericValidatorSelector, payload2);

    }

    function ex05SendMessageToAnL2CustomContract(uint256 playerL2MessageReceiver, uint256 functionSelector, uint256 player_l2_address) external {
        // Sending a message to a custom L2 contract
        // To collect points, you need to deploy an L2 contract that includes an l1 handler that can receive messages from L1.
        // To get point on this exercice you need to
        // - Deploy an L2 contract that will receive message sent from this function
        // - Call this function on L1
        // - A message is sent to your contract, as well as to the evaluator
        // - On L2, you call the evaluator to show that both values match
        // In order to call this function you need to specify:
        // - The address of your receiver contract on L2
        // - The function selector of your l1 handler in your L2 contract
        // - The L2 wallet on which you want to collect points

        // Creating an arbitrary random value
        uint256 rand_value = uint160(
            uint256(
                keccak256(abi.encodePacked(block.prevrandao, block.timestamp))
            )
        );
       
        // Sending a message to you l2 contract
        uint256[] memory payload_receiver = new uint256[](1);
        payload_receiver[0] = rand_value;
        starknetCore.sendMessageToL2(
            playerL2MessageReceiver,
            functionSelector,
            payload_receiver
        );

        // Sending a message to the evaluator 
        uint256[] memory payload_evaluator = new uint256[](3);
        payload_evaluator[0] = playerL2MessageReceiver;
        payload_evaluator[1] = rand_value;
        payload_evaluator[2] = player_l2_address;
        starknetCore.sendMessageToL2(l2Evaluator, ex05b_selector, payload_evaluator);
    }

    function ex06ReceiveMessageFromAnL2CustomContract(address playerL1MessageReceiver, uint256 player_l2_address) external {
        // Receiving a message from L2 on a custom L1 contract
        // To collect points, you need to deploy an L1 contract that is able to consume a message from L2
        // Step by step:
        // - Deploy an L1 contract that can consume messages from L2. 
        //      - Message consumption should happen in a function called consumeMessage(), callable by anyone
        // - Use the L2 evaluator to send a message to you L1 contract  
        // - Wait for the message to arrive on Ethereum
        // - Call this function ex05ReceiveMessageFromAnL2CustomContract to trigger the message consumption on your contract
        // - Points are sent back to your account contract on L2

        // No shenanigans, checking that player's contract is not the evaluator :) 
        require(playerL1MessageReceiver != address(this));
        // Connecting to the player's L1 contract        
        ISolution playerSolution = ISolution(playerL1MessageReceiver);
        // Calculating the message Hash
        uint256[] memory payload = new uint256[](1);
        payload[0] = player_l2_address;
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                l2Evaluator, // Who sent the message
                uint256(uint160(playerL1MessageReceiver)), // To whom was it sent
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
        uint256[] memory payload2 = new uint256[](2);
        // Adding player address on L2
        payload2[0] = player_l2_address;
        // Adding exercice number
        payload2[1] = 6;
        // Sending the message
        starknetCore.sendMessageToL2(l2Evaluator, genericValidatorSelector, payload2);
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
    function setEx05bSelector(uint256 ex05b_selector_) external onlyOwner {
        ex05b_selector = ex05b_selector_;
    }
    function setGenericValidatorSelector(uint256 genericValidatorSelector_) external onlyOwner {
        genericValidatorSelector = genericValidatorSelector_;
    }
}
