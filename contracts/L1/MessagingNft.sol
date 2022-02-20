// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/IStarknetCore.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MessagingNft is ERC721, Ownable {
    uint256 public tokenCounter;
    IStarknetCore starknetCore;
    uint256 private CLAIM_SELECTOR;
    uint256 private EvaluatorContractAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        address starknetCore_
    ) public ERC721(_name, _symbol) {
        starknetCore = IStarknetCore(starknetCore_);
        tokenCounter = 0;
    }

    function setClaimSelector(uint256 _claimSelector) external onlyOwner {
        CLAIM_SELECTOR = _claimSelector;
    }

    function setEvaluatorContractAddress(uint256 _evaluatorContractAddress)
        external
        onlyOwner
    {
        EvaluatorContractAddress = _evaluatorContractAddress;
    }

    function createNftFromL2(uint256 l2_user, uint256 playerL2Contract) public {
        uint256[] memory payload = new uint256[](1);
        payload[0] = uint256(uint160(msg.sender));
        // Consume the message from the StarkNet core contract.
        // This will revert the (Ethereum) transaction if the message does not exist.
        starknetCore.consumeMessageFromL2(playerL2Contract, payload);
        tokenCounter += 1;
        _safeMint(address(uint160(msg.sender)), tokenCounter);
        uint256[] memory sender_payload = new uint256[](2);
        sender_payload[0] = l2_user;
        sender_payload[1] = uint256(uint160(msg.sender));
        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(
            EvaluatorContractAddress,
            CLAIM_SELECTOR,
            sender_payload
        );
    }
}
