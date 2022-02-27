# StarkNet messaging bridge

PLAYERS BEWARE

THIS TUTORIAL IS STILL UNDER DEVELOPMENT. YOU CAN START WORKING ON IT, BUT YOUR BALANCES MAY BE RESET IN THE COMING DAYS.

## Introduction
Welcome! This is an automated workshop that will explain how to use the StarkNet L1 <-> L2 messaging bridge. 
- The first part allows you to send messages back and forth from L1 to L2, without necessarily having to code.
- The second part requires you to code smart contracts on L1 and L2 that are able to send messages to L2 and L1 counterparts.
- The second part requires you to code smart contracts on L1 and L2 that are able to receive messages from L2 and L1 counterparts.

It is aimed at developers that:
- Understand Cairo syntax
- Understand the Solidity syntax
- Understand the ERC20 token standard
- Understand the ERC721 standard
- Are willing to pull their sleeves up and get to work!
​
This workshop is the first in a series that will cover broad smart contract concepts (writing and deploying ERC20/ERC721, bridging assets, L1 <-> L2 messaging...). 
Interested in helping writing those? [Reach out](https://twitter.com/HenriLieutaud)!
​

### Disclaimer
​
Don't expect any kind of benefit from using this, other than learning a bunch of cool stuff about StarkNet, the first general purpose validity rollup on the Ethereum Mainnet.
​
StarkNet is still in Alpha. This means that development is ongoing, and the paint is not dry everywhere. Things will get better, and in the meanwhile, we make things work with a bit of duct tape here and there!
​

### Providing feedback
Once you are done working on this tutorial, your feedback would be greatly appreciated! 
**Please fill [this form](https://forms.reform.app/starkware/untitled-form-4/kaes2e) to let us know what we can do to make it better.** 
​
And if you struggle to move forward, do let us know! This workshop is meant to be as accessible as possible; we want to know if it's not the case.
​
Do you have a question? Join our [Discord server](https://discord.gg/YHz7drT3), register and join channel #tutorials-support
​

## How to work on this TD

## Points list

### Setting up
- Set up your environment (2 pts). 
These points will be attributed manually if you do not manage to have your contract interact with the evaluator, or automatically in the first question.

### Sending a message to L1, and back
Your tasks
- Write a L1 smart contract (A) that can receive messages from a L2 smart contract (B)
- Write (A) and (B)
- (A) should be the minter of an ERC20 token on L1
- (A) receives a message, sent by account (C) through (B) on L2, with two parameters: the receiver address (D) and the amount of tokens to mint.
- Once he receives tokens, (C) calls (A) on L1 to show he received the tokens properly (he has the tokens, and the message was consumed). This triggers a message from (A) to (B) which distribute points on L2 to (C)

### Sending a message to L1, and back (Implementation)
- Use a function to get assigned a private variable on the Evaluator
- Use a function to mint ERC20 tokens on L1 
- Consume message on L1 to get the tokens
- Show that you have the tokens to trigger points distribution on L2


### Sending a message to L1/L2 from L2/L1
- There is a contract on L1 (E) that can mint an ERC721 token.
- It can receive a message from any smart contract on L2, if the payload is formated correctly
- Player has to write a L2 contract that sends messages to (E), which will mint an ERC721 token
- (E) has a function with which users can submit an ERC721 token on L1 they received; and this mints tokens on L2 for them.
- There is a contract on L2 (F) that can mint an L2 ERC721 token.
- It can receive a message from any smart contract on L1, if the payload is formated correctly
- Player has to write a L1 contract that sends messages to (F), which will mint an ERC721 token
- (F) has a function with which users can submit an ERC721 token on L2 they received; and this mints tokens on L2 for them.

### Sending a message to L1/L2 from L2/L1 (Implementation)
- There is a contract on L1 (MessagingNft) that can mint an ERC721 token.
- It can receive a message from any smart contract on L2, if the payload is formated correctly
- Player has to write a L2 contract that sends messages to (MessagingNft), which will mint an ERC721 token
- Player has to submit the L2 contract that sends message for the minting to the Evaluator Contract
- Player has to call the ex1a from the evaluator contract with the correct fields
- Player has to consume the Message on L1 (MessagingNft), the points are distributed automatically to the player on L2 after the mint
- There is a contract on L2 (l2nft) that can mint an L2 ERC721 token.
- Player has to write a L1 contract that sends messages to the evaluator contract, which will mint an ERC721 token
- Player has to call ex2 on the evaluator contract



### Receiving a message on L1/L2 from L2/L1
- There is a contract on L1 (I) and another on L2 (J)
- Player has to create a L1 contract (K) that can receive message from (J) on L2
- (I) is called to check that (K) can receive messages from (J) (Check that message was not consumed; call K for it to consume message; check message was consumed)

Useful resources
https://starknet.io/documentation/l1-l2-messaging/#l1-l2-messaging
https://starknet.io/docs/hello_starknet/l1l2.html
https://github.com/l-henri/StarkNet-graffiti
https://twitter.com/HenriLieutaud/status/1466324729829154822

## Exercises & Contract addresses 
To be updated after deployment
​
​
