# StarkNet messaging bridge

Welcome! This is an automated workshop that will explain how to use the StarkNet L1 <-> L2 messaging bridge to create powerful cross layer applications.

It is aimed at developers that:

- Understand Cairo syntax
- Understand the Solidity syntax
- Understand the ERC20 token standard
- Understand the ERC721 standard

## Introduction

### Disclaimer

​
Don't expect any kind of benefit from using this, other than learning a bunch of cool stuff about StarkNet, the first general purpose validity rollup on the Ethereum Mainnnet.
​
StarkNet is still in Alpha. This means that development is ongoing, and the paint is not dry everywhere. Things will get better, and in the meanwhile, we make things work with a bit of duct tape here and there!
​

### How it works

The goal of this tutorial is for you to create and deploy contracts on StarkNet and Ethereum that will interact with each other. In other words, you will create your own L1 <-> L2 bridge.

Your progress will be check by an [evaluator contract](contracts/Evaluator.cairo), deployed on StarkNet, which will grant you points in the form of [ERC20 tokens](contracts/token/ERC20/TDERC20.cairo).

Each exercise will require you to add functionnality to your bridge.

- The first part allows you to send messages back and forth from L1 to L2, without necessarily having to code.
- The second part requires you to code smart contracts on L1 and L2 that are able to send messages to L2 and L1 counterparts.
- The second part requires you to code smart contracts on L1 and L2 that are able to receive messages from L2 and L1 counterparts.

For each exercise, you will have to write a new version on your contract, deploy it, and submit it to the evaluator for correction.
​
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

## Getting ready to work

### Step 1 - Clone the repo

```bash
git clone https://github.com/starknet-edu/starknet-messaging-bridge
cd starknet-messaging-bridge
```

### Step 2 - Set up your environment

There are two ways to set up your environment on StarkNet: a local installation, or using a docker container

- For Mac and Linux users, we recommend either
- For windows users we recommand docker

For a production setup instructions we wrote [this article](https://medium.com/starknet-edu/the-ultimate-starknet-dev-environment-716724aef4a7).

#### Option A - Set up a local python environment

- Set up the environment following [these instructions](https://starknet.io/docs/quickstart.html#quickstart)
- Install [OpenZeppelin's cairo contracts](https://github.com/OpenZeppelin/cairo-contracts).

```bash
pip install openzeppelin-cairo-contracts
```

#### Option B - Use a dockerized environment

- Linux and macos

for mac m1:

```bash
alias cairo='docker run --rm -v "$PWD":"$PWD" -w "$PWD" shardlabs/cairo-cli:latest-arm'
```

for amd processors

```bash
alias cairo='docker run --rm -v "$PWD":"$PWD" -w "$PWD" shardlabs/cairo-cli:latest'
```

- Windows

```bash
docker run --rm -it -v ${pwd}:/work --workdir /work shardlabs/cairo-cli:latest
```

### Step 3 -Test that you are able to compile the project

```bash
starknet-compile contracts/Evaluator.cairo
```

​
​

## Working on the tutorial

### Workflow

L2 -> L1 communication takes ~30 mins so it is recommended to send the messages from L2 to L1 as soon as possible and to do the exercises on L1 in the meantime.

To do this tutorial you will have to interact with the [`Evaluator.cairo`](contracts/Evaluator.cairo) contract. To validate an exercise you will have to

- Read the evaluator code to figure out what is expected of your contract
- Customize your contract's code
- Deploy it to StarkNet's testnet. This is done using the CLI.
- Register your exercise for correction, using the `submit_exercise` function on the evaluator. This is done using Voyager.
- Call the relevant function on the evaluator contract to get your exercise corrected and receive your points. This is done using Voyager.
- There is also an [evaluator contract](contracts/L1/Evaluator.sol) on L1, that will check your solidity work. The workflow to use it is the same as above, only on L1.

### Exercises & Contract addresses

| Contract code                                                                                                                    | Contract on voyager                                                                                                                                                           |
| -------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [L2 Evaluator](contracts/Evaluator.cairo)                                                                                        | [0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99](https://goerli.voyager.online/contract/0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99) |
| [Points counter ERC20](contracts/token/ERC20/TDERC20.cairo)                                                                      | [0x38ec18163a6923a96870f3d2b948a140df89d30120afdf90270b02c609f8a88](https://goerli.voyager.online/contract/0x38ec18163a6923a96870f3d2b948a140df89d30120afdf90270b02c609f8a88) |
| [L2 Dummy NFT](contracts/l2nft.cairo)                                                                                            | [0x6cc3df14b8b3e8c05ad19c74f373e110bba0380b2799bcd9f717d31d2757625](https://goerli.voyager.online/contract/0x6cc3df14b8b3e8c05ad19c74f373e110bba0380b2799bcd9f717d31d2757625) |
| [L1 Evaluator](contracts/L1/Evaluator.sol)                                                                                       | [0x8055d587A447AE186d1589F7AAaF90CaCCc30179](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179)                                                  |
| [L1 Dummy token](contracts/L1/DummyToken.sol)                                                                                    | [0x0232CB90523F181Ab4990Eb078Cf890F065eC395](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395)                                                  |
| [L1 Messaging NFT](contracts/L1/MessagingNft.sol)                                                                                | [0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E)                                                  |
| [StarkNet Core Contract Proxy](https://goerli.etherscan.io/address/0xde29d060d45901fb19ed6c6e959eb22d8626708e#readContract)      | [0xde29d060D45901Fb19ED6C6e959EB22d8626708e](https://goerli.etherscan.io/address/0xde29d060d45901fb19ed6c6e959eb22d8626708e)                                                  |
| [Goerli Faucet (0.1 ETH / 2 hours)](https://goerli.etherscan.io/address/0x25864095d3eB9F7194C1ccbb01871c9b1bd5787a#readContract) | [0x25864095d3eB9F7194C1ccbb01871c9b1bd5787a](https://goerli.etherscan.io/address/0x25864095d3eB9F7194C1ccbb01871c9b1bd5787a#writeContract)                                    |

## Tasks list

### Exercise 0 - Send an L2→L1→L2 message with existing contracts (2 pts)

Use a predeployed contract to mint ERC20 tokens on L1 from L2. A secret message is passed with the messages; be sure to find it in order to collect your points.

- Call function [`ex_0_a`](contracts/Evaluator.cairo#L121) of [*L2 Evaluator*](https://goerli.voyager.online/contract/0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99)
  - You need to specify an L1 address, and an amount of ERC20 to mint
  - The secret message is sent from L2 to L1 at this stage.
- Call [`mint`](contracts/L1/DummyToken.sol#L37) of [*L1 DummyToken*](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395)
  - You need to show that you know the secret value at this step
- Call [`i_have_tokens`](contracts/L1/DummyToken.sol#L48) of [*L1 DummyToken*](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395)
  - This function checks that you have indeed been able to mint ERC20 tokens, and will then send a message back to L2 to credit your points
  - This is done using [`ex_0_b`](contracts/Evaluator.cairo#L143) of the L2 evaluator

### Exercise 1 - Send an L2→L1 message with your contract (2 pts)

Write and deploy a contract on L2 that *sends* messages to L1.

- Write a contract on L2 that will send a message to [L1 MessagingNft](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E) and trigger [`createNftFromL2`](contracts/L1/MessagingNft.sol#L35)
  - Your function should be called [`create_l1_nft_message`](contracts/Evaluator.cairo#L198)
- Deploy your contract
- Submit the contract address to L2 Evaluator by calling its [`submit_exercise`](contracts/Evaluator.cairo#L166)
- Call [`ex1a`](contracts/Evaluator.cairo#L188) of L2 Evaluator to trigger the message sending to L2
- Call [`createNftFromL2`](contracts/L1/MessagingNft.sol#L35) of L1 MessagingNft to trigger the message consumption on L1
  - L1 MessagingNft [sends back](contracts/L1/MessagingNft.sol#L47) a message to L2 to [credit your points](contracts/Evaluator.cairo#L205) on L2

### Exercise 2 - Send an L1→L2 message with your contract (2 pts)

Write and deploy a contract on L1 that *sends* messages to L2.

- Write a contract on L1 that will send a message to L2 Evaluator and trigger [`ex2`](contracts/Evaluator.cairo#L221)
  - You can check how L1 MessagingNft [sends](contracts/L1/MessagingNft.sol#L47) a message to L2 to get some ideas
  - You can get latest address of the StarkNet Core Contract Proxy on Goerli by running `starknet get_contract_addresses --network alpha-goerli` in your CLI
  - Learn how to get the [selector](https://starknet.io/docs/hello_starknet/l1l2.html#receiving-a-message-from-l1) of a StarkNet contract function
- Deploy your contract
- Trigger the message sending on L1. Your  points are automatically attributed on L2.

### Exercise 3 - Receive an L2→L1 message with your contract (2 pts)

- Write a contract on L1 that will receive a message from  from function [`ex3_a`](contracts/Evaluator.cairo#L231).
  - Make sure your contract is able to handle the message.
  - Your message consumption function should be called [`consumeMessage`](contracts/L1/Evaluator.sol#L51)
- Deploy your L1 contract
- Call [`ex3_a`](contracts/Evaluator.cairo#L231) of [*L2 Evaluator*](https://goerli.voyager.online/contract/0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99) to send an L2→L1 message
- Call [`ex3`](contracts/L1/Evaluator.sol#L32)of *L1 Evaluator*, which triggers message consumption from your L1 contract
  - L1 evaluator will also [send back](contracts/L1/Evaluator.sol#L57) a message to L2 to distribute your points

### Exercise 4 - Receive an L1→L2 message with your contract (2 pts)

- Write a L2 contract that is able to receive a message from [`ex4`](contracts/L1/Evaluator.sol#L60) of [*L1 Evaluator*](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179)
  - You can name your function however you like, since you provide the function selector as a parameter on L1
- Deploy your contract on L2
- Call [`ex4`](contracts/L1/Evaluator.sol#L60) of *L1 Evaluator* to send the random value out to your L2 contract
- Submit your L2 contract address by calling [`submit_exercise`](contracts/Evaluator.cairo#L166) of *L2 Evaluator*
- Call [`ex4_b`](contracts/Evaluator.cairo#L266) of *L2 Evaluator* that will check you completed your work correctly and distribute your points

## Annex - Useful tools and ressources

### Converting data to and from decimal

To convert data to felt use the [`utils.py`](utils.py) script
To open Python in interactive mode after running script

  ```bash
  python -i utils.py
  ```

  ```python
  >>> str_to_felt('ERC20-101')
  1278752977803006783537
  ```

### Checking your progress & counting your points

​
Your points will get credited in your wallet; though this may take some time. If you want to monitor your points count in real time, you can also see your balance in voyager!
​

- Go to the  [ERC20 counter](https://goerli.voyager.online/contract/0x38ec18163a6923a96870f3d2b948a140df89d30120afdf90270b02c609f8a88#readContract)  in voyager, in the "read contract" tab
- Enter your address in decimal in the "balanceOf" function

You can also check your overall progress [here](https://starknet-tutorials.vercel.app)
​

### Transaction status

​
You sent a transaction, and it is shown as "undetected" in voyager? This can mean two things:
​

- Your transaction is pending, and will be included in a block shortly. It will then be visible in voyager.
- Your transaction was invalid, and will NOT be included in a block (there is no such thing as a failed transaction in StarkNet).
​
You can (and should) check the status of your transaction with the following URL  [https://alpha4.starknet.io/feeder_gateway/get_transaction_receipt?transactionHash=](https://alpha4.starknet.io/feeder_gateway/get_transaction_receipt?transactionHash=)  , where you can append your transaction hash.
​

### Articles & documentation

- [Messaging Mechanism | StarkNet Docs](https://docs.starknet.io/docs/L1%3C%3EL2%20Communication/messaging-mechanism)
- [Interacting with L1 contracts | StarkNet Documentation](https://starknet.io/docs/hello_starknet/l1l2.html)
- Sample Project: [StarkNet graffiti | GitHub](https://github.com/l-henri/StarkNet-graffiti)
- [Thread on StarkNet ⇄ Ethereum Messaging | Twitter](https://twitter.com/HenriLieutaud/status/1466324729829154822)
