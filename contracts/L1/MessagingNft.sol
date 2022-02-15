// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/IStarknetCore.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MessagingNft is ERC721, Ownable {
    uint256 public tokenCounter;
    IStarknetCore starknetCore;
    uint256 private CLAIM_SELECTOR;

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

    function createNftFromL2(uint256 l2ContractAddress, uint256 l1_user)
        public
    {
        uint256[] memory payload = new uint256[](1);
        payload[0] = l1_user;
        // Consume the message from the StarkNet core contract.
        // This will revert the (Ethereum) transaction if the message does not exist.
        starknetCore.consumeMessageFromL2(l2ContractAddress, payload);
        tokenCounter += 1;
        _safeMint(address(uint160(l1_user)), tokenCounter);
    }

    function submitNft(uint256 l2ContractAddress, uint256 l2user) external {
        require(
            balanceOf(msg.sender) > 0,
            "The user's balance is equal to 0 !."
        );

        // Construct the deposit message's payload.
        uint256[] memory payload = new uint256[](2);
        payload[0] = l2user;
        payload[1] = uint256(uint160(msg.sender));
        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(
            l2ContractAddress,
            CLAIM_SELECTOR,
            payload
        );
    }
}
