// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

interface ISolution {
    function consumeMessage(uint256 l2ContractAddress, uint256 l2User) external;
}
