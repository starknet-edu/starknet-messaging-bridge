# StarkNet messaging bridge

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

## Table of contents

- [StarkNet messaging bridge](#starknet-messaging-bridge)
  - [Introduction](#introduction)
    - [Disclaimer](#disclaimer)
    - [Providing feedback](#providing-feedback)
  - [Table of contents](#table-of-contents)
  - [How to work on this tutorial](#how-to-work-on-this-tutorial)
    - [Before you start](#before-you-start)
      - [L2](#l2)
      - [L1](#l1)
    - [Counting your points](#counting-your-points)
      - [Transaction status](#transaction-status)
      - [Install nile](#install-nile)
        - [With pip](#with-pip)
        - [With docker](#with-docker)
    - [Getting to work](#getting-to-work)
  - [Exercises & Contract addresses](#exercises--contract-addresses)
  - [Points list](#points-list)
    - [Sending a message to L1, and back](#sending-a-message-to-l1-and-back)
    - [Sending a message to L1 from L2 (Implementation)](#sending-a-message-to-l1-from-l2-implementation)
    - [Sending a message to L2 from L1](#sending-a-message-to-l2-from-l1)
    - [Receiving a message on L1 from L2](#receiving-a-message-on-l1-from-l2)
    - [Receiving a message on L2 from L1](#receiving-a-message-on-l2-from-l1)

## How to work on this tutorial

### Before you start

L2 -> L1 communication takes ~30 mins so it is recommended to send the messages from L2 to L1 as soon as possible and to do the exercises on L1 in the meantime.

The tutorial has multiple components:

#### L2

- An [evaluator contract](contracts/Evaluator.cairo), that is able to mint and distribute `L1L2-101` points
- An [ERC20 token](contracts/token/ERC20/TDERC20.cairo), ticker `L1L2-101`, that is used to keep track of points
- An [ERC721 token](contracts/l2nft.cairo), "L2 nft", ticker `L2NFT`

#### L1

- An [evaluator contract](contracts/L1/Evaluator.sol), that will communicate with the evaluator on L2
- An [ERC20 token](contracts/L1/DummyToken.sol), ticker `TDD`
- An [ERC721 token](contracts/L1/MessagingNft.sol), "L2 nft", ticker `MNT`

### Counting your points

Your points will get credited in your wallet; though this may take some time. If you want to monitor your points count in real time, you can also see your balance in voyager!
​

- Go to the  [ERC20 counter](https://goerli.voyager.online/contract/0x01c1a868018f540bc456d2ba4859d20b06a8542fa447cd499f7372d9fd1c1bf9#readContract)  in voyager, in the "read contract" tab
- Enter your address in decimal in the "balanceOf" function

You can also check your overall progress [here](https://starknet-tutorials.vercel.app)


#### Transaction status

You sent a transaction, and it is shown as "undetected" in voyager? This can mean two things:

- Your transaction is pending, and will be included in a block shortly. It will then be visible in voyager.
- Your transaction was invalid, and will NOT be included in a block (there is no such thing as a failed transaction in StarkNet).

You can (and should) check the status of your transaction with the following URL  [https://alpha4.starknet.io/feeder_gateway/get_transaction_receipt?transactionHash=](https://alpha4.starknet.io/feeder_gateway/get_transaction_receipt?transactionHash=) , where you can append your transaction hash.

#### Install nile

##### With pip

- Set up the environment following [these instructions](https://starknet.io/docs/quickstart.html#quickstart)
- Install [Nile](https://github.com/OpenZeppelin/nile).

##### With docker

- Linux and macos

```bash
alias nile='docker run --rm -v "$PWD":"$PWD" -w "$PWD" lucaslvy/nile:0.8.0-x86'
```

for M1 macs you can use this image instead `lucaslvy/nile:0.8.0-arm`

- Windows

```powershell
docker run --rm -it -v ${pwd}:/work --workdir /work lucaslvy/nile:0.8.0-x86
```

### Getting to work

- Clone the repo on your machine
- Test that you are able to compile the project

```bash
nile compile
```

- To convert data to felt use the [`utils.py`](utils.py) script

## Exercises & Contract addresses

| Contract code                                               | Contract on voyager                                                                                                                                                             |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [L2 Evaluator](contracts/Evaluator.cairo)                   | [0x02a77bb771fdcb0966639bab6e2b5842e7d0e7dff2f8258e3aee8e38695d98f6](https://goerli.voyager.online/contract/0x02a77bb771fdcb0966639bab6e2b5842e7d0e7dff2f8258e3aee8e38695d98f6)   |
| [Points counter ERC20](contracts/token/ERC20/TDERC20.cairo) | [0x01c1a868018f540bc456d2ba4859d20b06a8542fa447cd499f7372d9fd1c1bf9](https://goerli.voyager.online/contract/0x01c1a868018f540bc456d2ba4859d20b06a8542fa447cd499f7372d9fd1c1bf9) |
| [l2nft](contracts/l2nft.cairo)                              | [0x008b7c46e561bf4b7c0ad39716386207041310900742c980253024e3b6be1314](https://goerli.voyager.online/contract/0x008b7c46e561bf4b7c0ad39716386207041310900742c980253024e3b6be1314) |
| [L1 Evaluator](contracts/L1/Evaluator.sol)                  | [0x8055d587A447AE186d1589F7AAaF90CaCCc30179](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179)                                                    |
| [L1 Dummy token](contracts/L1/DummyToken.sol)               | [0x0232CB90523F181Ab4990Eb078Cf890F065eC395](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395)                                                    |
| [L1 Messaging NFT](contracts/L1/MessagingNft.sol)           | [0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E)                                                    |

StarkNet Core contract: 0xde29d060D45901Fb19ED6C6e959EB22d8626708e
[Goerli faucet](https://goerli.etherscan.io/address/0x25864095d3eB9F7194C1ccbb01871c9b1bd5787a#writeContract) (0.1 ether every 2 hours)

## Points list

### Sending a message to L1, and back

- Use a function (ex_0_a) of the [L2 Evaluator](https://goerli.voyager.online/contract/0x02a77bb771fdcb0966639bab6e2b5842e7d0e7dff2f8258e3aee8e38695d98f6) to mint ERC20 tokens on L1
- Mint tokens on L1 [DummyToken](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395) by consuming the message with the secret value
- Show that you have the tokens (`i_have_tokens`) to trigger points distribution on L2 (2 pts)

### Sending a message to L1 from L2 (Implementation)

- There is a contract on [L1 MessagingNft](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E) that can mint an ERC721 token.
- It can receive any message from any smart contract on L2, if the payload is formated correctly
- Player has to write a L2 contract that sends messages to (MessagingNft), which will mint an ERC721 token
- Player has to submit the L2 contract that sends message for the minting to the [L2 Evaluator](https://goerli.voyager.online/contract/0x02a77bb771fdcb0966639bab6e2b5842e7d0e7dff2f8258e3aee8e38695d98f6)
- Player has to call the ex1a() from the evaluator
- Player has to consume the Message on L1 [MessagingNft](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E), the points are distributed automatically to the player on L2 after the mint (2 pts)

### Sending a message to L2 from L1

- There is a contract on L2 [l2nft](https://goerli.voyager.online/contract/0x008b7c46e561bf4b7c0ad39716386207041310900742c980253024e3b6be1314) that can mint an L2 ERC721 token.
- Player has to write a L1 contract that sends messages to the [L2 Evaluator](https://goerli.voyager.online/contract/0x02a77bb771fdcb0966639bab6e2b5842e7d0e7dff2f8258e3aee8e38695d98f6), which will mint an ERC721 token (2 pts)

### Receiving a message on L1 from L2

- Player has to write a L1 contract that consumes messages from L2
- Player has to call ex3_a() from [L2 Evaluator](https://goerli.voyager.online/contract/0x02a77bb771fdcb0966639bab6e2b5842e7d0e7dff2f8258e3aee8e38695d98f6)
- Player has to call ex3() from [L1 Evaluator](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179) in order to consume the message and trigger points distribution (2 pts)

### Receiving a message on L2 from L1

- Player has to create a L2 contract that can receive message from [L1 Evaluator](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179) in order to set the random value assigned on the message
- Player has to call ex4_b() from [L2 Evaluator](https://goerli.voyager.online/contract/0x02a77bb771fdcb0966639bab6e2b5842e7d0e7dff2f8258e3aee8e38695d98f6) in order to get the points (2 pts)

Useful resources
<https://starknet.io/documentation/l1-l2-messaging/#l1-l2-messaging>  
<https://starknet.io/docs/hello_starknet/l1l2.html>  
<https://github.com/l-henri/StarkNet-graffiti>  
<https://twitter.com/HenriLieutaud/status/1466324729829154822>  
