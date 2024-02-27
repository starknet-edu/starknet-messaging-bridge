# DISCLAIMER
Hello Starknet community, this repository is not updated with the latest Cairo syntax and hence, we do not recommend to attempt this tutorial as of today. If you are interested in contributing to the repository to update the tutorial, please create a PR and tag me @gyan0890 on it and we will be happy to support you with the process.

A great resource to get you up to speed with the new Cairo syntax in a Starknet context is [Chapter 2 of the Starknet Book](https://book.starknet.io/chapter_2/index.html).

You can also ping me(@gyanlakshmi) on Telegram to help you assign the right tasks.

# StarkNet messaging bridge

Welcome! This is an automated workshop that will explain how to use the StarkNet L1 <-> L2 messaging bridge to create powerful cross layer applications.

It is aimed at developers that:

- Understand Cairo syntax (not familiar yet? [Click here](https://cairo-book.github.io/))
- Understand the Solidity syntax

## Introduction

### How it works

The goal of this tutorial is for you to create and deploy contracts on StarkNet and Ethereum that will interact with each other. In other words, you will create your own L1 <-> L2 bridge.

Your progress will be check by an [evaluator contract](src/evaluator.cairo), deployed on StarkNet, which will grant you points in the form of [ERC20 tokens](src/token/TDERC20.cairo), deployed at address `0x031d9e05ec67956acfec4768f7b302a56f8a256686fa077594f6dde40d5ca04c`.

Another evaluator is deployed on L1 ([evaluator contract](contracts/Evaluator.sol)). It will check your work on L1, and send back instructions to the L2 evaluator to credit you points on L2.

Each exercise will allow you to explore the Starknet messaging bridge in a step by step way. Be sure to check both sides of the exercice - on L1 and L2.

- In exercice 1 you will use the L1 evaluator to send a message to the L2 evaluator
- In exercice 2 you will use the L2 evaluator to send a message to the L1 evaluator
- In exercise 3 you will deploy an L1 contract that sends a message to the L2 evaluator
- In exercise 4 you will deploy an L2 contract that sends a message to the L1 evaluator
- In exercise 5 you will deploy an L2 contract that receives a message from the L1 evaluator
- In exercise 6 you will deploy an L1 contract that receives a message from the L2 evaluator
​
### Getting ready to work
- Get ready to work by following the instructions in [Chapter 1 of the Starknet Book](https://book.starknet.io/chapter_1/index.html)
- You should install `scarb`, `cairo-lang` and `hardhat`
- Get some Goerli Eth on Starknet. Claim some on the [faucet](https://faucet.goerli.starknet.io/) or bridge some using [Starkgate](https://goerli.starkgate.starknet.io/)

### Evaluators addresses
- The L2 Evaluator is accessible on [Starkscan](https://testnet.starkscan.co/contract/0x0455c60bbd52b3b57076a0180e7588df61046366ad5a48bc277c974518f837c4) or [Voyager](https://goerli.voyager.online/contract/0x04732b911740d44f8916db5e49ad3cb20aa2969afc942923eed04bf185738636) at address `0x0455c60bbd52b3b57076a0180e7588df61046366ad5a48bc277c974518f837c4`
- The L1 evaluator is accessible on [Etherscan](https://goerli.etherscan.io/address/0x94210fB83a2C1e548add07026DaA294a440Ae86d) at address `0x94210fB83a2C1e548add07026DaA294a440Ae86d`

## Working on the tutorial
L2 -> L1 communication takes ~30 mins so it is recommended to complete the L2 -> L1 part with care, and then start working on the next exercice while the message is passed.

### Exercises & Contract addresses
- The L2 evaluator is deployed at address ``, you can interact with it using [Starkscan]() or [Voyager]()
- The L1 evaluator is deployed at address ``, you can interact with it using [Etherscan]()

## Tasks list

### Exercise 1 - Send an L1→L2 message with an existing contract (2 pts)

- To validate this exercice, you need to successfully call `ex01SendMessageToL2()` on the [L1 evaluator](contracts/Evaluator.sol)
- It will then send a message to the [L2 evaluator](src/evaluator.cairo) and trigger function `ex_01_receive_message_from_l1()`, which will credit you points.
- Be careful! There is a constraint on the value of "message"

### Exercise 2 - Send an L2→L1 message with an existing contract (2 pts)

- To validate this exercice, you need to successfully call `ex_02_send_message_to_l1()` on the [L2 evaluator](src/evaluator.cairo)
- It will then send a message to the [L1 evaluator](contracts/Evaluator.sol) 
- You will then have to trigger function `ex02ReceiveMessageFromL2()` on the L1 evaluator. This function will validate your answer, and send instructions to the L2 evaluator, through the L1 handler `validate_from_l1()`, which will credit you points
- Be careful! There is a constraint on the value of "message"

### Exercise 3 - Send an L1→L2 message with your own contract (2 pts)

- To validate this exercice, you need to write and deploy an L1 smart contract that calls the `ex_03_receive_message_from_l1_contract()` L1 handler on the [L2 evaluator](src/evaluator.cairo)
- The handler will credit points to your account

### Exercise 4 - Send an L2→L1 message with existing contracts (2 pts)

- To validate this exercice, you need to write and deploy an L2 smart contract that sends a message to the [L1 evaluator](contracts/Evaluator.sol) 
- Once the message arrived, you then need to trigger the function `ex04ReceiveMessageFromAnL2Contract()` on the L1 evaluator. This function will consume the message you sent, and send instructions to the L2 evaluator, through the L1 handler `validate_from_l1()`, which will credit you points
- Be careful, there are constraints on the EOA that triggers the function!

### Exercise 5 - Receive an L1→L2 message with your own contract (2 pts)

- To validate this exercice, you need to write and deploy an L2 smart contract that can receive messages from the [L1 evaluator](contracts/Evaluator.sol) 
- You then need to call `ex05SendMessageToAnL2CustomContract()` on the L1 evaluator. This function will send a random value to your contract, as well as to the L2 evaluator. Your L2 contract needs to store that variable, and make it visible with a view function called `random_value()`
- Once both messages arrived, you need to call `ex_05_check_result()` on the L2 evaluator. This function will call `random_value()` on your deployed L2 contract, and check wether the random value received matches the one he received

### Exercise 6 - Receive an L2→L1 message with existing contracts (2 pts)

- To validate this exercice, you need to write and deploy an L1 smart contract that can receive messages from the [L2 evaluator](src/evaluator.cairo)
- Your L1 contract needs to have a function `consumeMessage()` that triggers L2 message consumption
- Once the message arrived, you  need to trigger the function `ex06ReceiveMessageFromAnL2CustomContract()` on the L1 evaluator. This function will call `consumeMessage()`  on your L1 contract, and check that your contract was able to consume the message correctly.
- It will then send instructions to the L2 evaluator, through the L1 handler `validate_from_l1()`, which will credit you points

## Annex - Useful tools and ressources

### Checking your progress & counting your points

​
Your points will get credited in your wallet! Add token `0x031d9e05ec67956acfec4768f7b302a56f8a256686fa077594f6dde40d5ca04c` and check from time to time.
​

### Articles & documentation

- [Messaging Mechanism | StarkNet Docs](https://docs.starknet.io/documentation/architecture_and_concepts/L1-L2_Communication/messaging-mechanism/)
- [Thread on StarkNet ⇄ Ethereum Messaging | Twitter](https://twitter.com/HenriLieutaud/status/1466324729829154822)

### Disclaimer

​
Don't expect any kind of benefit from using this, other than learning a bunch of cool stuff about StarkNet, the first general purpose validity rollup on the Ethereum Mainnet.
​
StarkNet is still in Alpha. This means that development is ongoing, and the paint is not dry everywhere. Things will get better, and in the meanwhile, we make things work with a bit of duct tape here and there!
​


### Where am I?

This workshop is the fourth in a series aimed at teaching how to build on StarkNet. Checkout out the following:

| Topic                                          | GitHub repo                                                                            |
| ---------------------------------------------- | -------------------------------------------------------------------------------------- |
| Learn how to read Cairo code                   | [Cairo 101](https://github.com/starknet-edu/starknet-cairo-101)                        |
| Deploy and customize an ERC721 NFT             | [StarkNet ERC721](https://github.com/starknet-edu/starknet-erc721)                     |
| Deploy and customize an ERC20 token            | [StarkNet ERC20](https://github.com/starknet-edu/starknet-erc20)                       |
| Build a cross layer application (you are here) | [StarkNet messaging bridge](https://github.com/starknet-edu/starknet-messaging-bridge) |
| Debug your Cairo contracts easily              | [StarkNet debug](https://github.com/starknet-edu/starknet-debug)                       |
| Design your own account contract               | [StarkNet account abstraction](https://github.com/starknet-edu/starknet-accounts)      |

### Providing feedback & getting help

Once you are done working on this tutorial, your feedback would be greatly appreciated!

**Please fill out [this form](https://forms.reform.app/starkware/untitled-form-4/kaes2e) to let us know what we can do to make it better.**

​
And if you struggle to move forward, do let us know! This workshop is meant to be as accessible as possible; we want to know if it's not the case.

​
Do you have a question? Join our [Discord server](https://starknet.io/discord), register, and join channel #tutorials-support
​

### Contributing

This project can be made better and will evolve as StarkNet matures. Your contributions are welcome! Here are things that you can do to help:

- Create a branch with a translation to your language
- Correct bugs if you find some
- Add an explanation in the comments of the exercise if you feel it needs more explanation

​
