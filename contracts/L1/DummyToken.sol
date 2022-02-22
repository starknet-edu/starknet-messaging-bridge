// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IStarknetCore.sol";

contract DummyToken is ERC20, Ownable {
    uint256 private CLAIM_SELECTOR;
    uint256 private l2ContractAddress;
    // The StarkNet core contract.
    IStarknetCore starknetCore;

    constructor(
        string memory name_,
        string memory symbol_,
        address starknetCore_
    ) ERC20(name_, symbol_) {
        starknetCore = IStarknetCore(starknetCore_);
    }

    function claimSelector() public view virtual returns (uint256) {
        return CLAIM_SELECTOR;
    }

    function setClaimSelector(uint256 _claimSelector) external onlyOwner {
        CLAIM_SELECTOR = _claimSelector;
    }

    function setl2ContractAddress(uint256 _l2ContractAddress)
        external
        onlyOwner
    {
        l2ContractAddress = _l2ContractAddress;
    }

    function mint(uint256 amount, uint256 secret_value) external {
        uint256[] memory payload = new uint256[](3);
        payload[0] = uint256(uint160(msg.sender));
        payload[1] = amount;
        payload[2] = secret_value;
        // Consume the message from the StarkNet core contract.
        // This will revert the (Ethereum) transaction if the message does not exist.
        starknetCore.consumeMessageFromL2(l2ContractAddress, payload);
        _mint(msg.sender, amount);
    }

    function i_have_tokens(uint256 l2_user, uint256 secret_value) external {
        require(
            balanceOf(msg.sender) > 0,
            "The user's balance is equal to 0 !."
        );

        // Construct the deposit message's payload.
        uint256[] memory payload = new uint256[](3);
        payload[0] = l2_user;
        payload[1] = uint256(uint160(msg.sender));
        payload[2] = secret_value;

        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(
            l2ContractAddress,
            CLAIM_SELECTOR,
            payload
        );
    }
}
