// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IStarknetCore.sol";
import "./interfaces/ISolution.sol";

contract ExerciseSolution is ISolution {
    uint256 L2_EVALUATOR =
        0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99;
    IStarknetCore starknetCore =
        IStarknetCore(0xde29d060D45901Fb19ED6C6e959EB22d8626708e);
    uint256 L2_USER_ADDRESS =
        0x073eb291861D13Aa2584626Fb8759ACbDAD2C513A487254a993D6Fd2c6dC3Be4;

    event Success(uint256 l2Evaluator, uint256 l1User);

    function consumeMessage(uint256 l2Evaluator, uint256 l2User)
        external
        override
    {
        uint256[] memory payload = new uint256[](1);
        payload[0] = L2_USER_ADDRESS;

        starknetCore.consumeMessageFromL2(L2_EVALUATOR, payload);

        emit Success(l2Evaluator, l2User);
    }

    uint256 EX2_FUNCTION_SELECTOR =
        897827374043036985111827446442422621836496526085876968148369565281492581228;

    function sendMessageToEx2() external {
        uint256[] memory payload = new uint256[](1);
        payload[0] = L2_USER_ADDRESS;

        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(
            L2_EVALUATOR,
            EX2_FUNCTION_SELECTOR,
            payload
        );
    }
}
