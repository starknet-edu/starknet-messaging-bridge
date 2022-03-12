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

### Counting your points
Your points will get credited in Argent X; though this may take some time. If you want to monitor your points count in real time, you can also see your balance in voyager!
​
-   Go to the  [ERC20 counter](https://goerli.voyager.online/contract/0x06334ec396a4110ace68be4ff5d1579af2042abebae12632e32fc567bc461ed1#readContract)  in voyager, in the "read contract" tab
-   Enter your address in decimal in the "balanceOf" function

## Points list

### Sending a message to L1, and back
- Use a function (ex_0_a) of the [Evaluator](https://goerli.voyager.online/contract/0x195bcd27328405ef78ddc6c47b2258705dfa3bea21f7e887e66475664b84c5b) to mint ERC20 tokens on L1 
- Mint tokens on L1 [DummyToken](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395) by consuming the message with the secret value 
- Show that you have the tokens to trigger points distribution on L2

### Sending a message to L1 from L2 (Implementation)
- There is a contract on L1 [MessagingNft](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E) that can mint an ERC721 token.
- It can receive a message from any smart contract on L2, if the payload is formated correctly
- Player has to write a L2 contract that sends messages to (MessagingNft), which will mint an ERC721 token
- Player has to submit the L2 contract that sends message for the minting to the [Evaluator](https://goerli.voyager.online/contract/0x195bcd27328405ef78ddc6c47b2258705dfa3bea21f7e887e66475664b84c5b)
- Player has to call the ex1a() from the evaluator 
- Player has to consume the Message on L1 [MessagingNft](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E), the points are distributed automatically to the player on L2 after the mint
### Sending a message to L2 from L1
- There is a contract on L2 [l2nft](https://goerli.voyager.online/contract/0x03fee3d8ed3c3f139aee59658402f5e1e132caf9bd9d13c6f767024a824f7470) that can mint an L2 ERC721 token.
- Player has to write a L1 contract that sends messages to the [Evaluator](https://goerli.voyager.online/contract/0x195bcd27328405ef78ddc6c47b2258705dfa3bea21f7e887e66475664b84c5b), which will mint an ERC721 token

### Receiving a message on L1 from L2
- Player has to write a L1 contract that consume message from L2
- Player has to call ex3_a() from [L2 Evaluator](https://goerli.voyager.online/contract/0x195bcd27328405ef78ddc6c47b2258705dfa3bea21f7e887e66475664b84c5b)
- Player has to call ex3() from [L1 Evaluator](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179) in order to consume the message and trigger points distribution
### Receiving a message on L2 from L1
- Player has to create a L2 contract that can receive message from [L1 Evaluator]https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179) in order to set the random value assigned on the message
- Player has to call ex4_b() from [L2 Evaluator](https://goerli.voyager.online/contract/0x195bcd27328405ef78ddc6c47b2258705dfa3bea21f7e887e66475664b84c5b) in order to get the points

Useful resources
https://starknet.io/documentation/l1-l2-messaging/#l1-l2-messaging
https://starknet.io/docs/hello_starknet/l1l2.html
https://github.com/l-henri/StarkNet-graffiti
https://twitter.com/HenriLieutaud/status/1466324729829154822

## Exercises & Contract addresses 
​|Contract code|Contract on voyager|
|---|---|
|[Points counter ERC20](contracts/token/ERC20/TDERC20.cairo)|[0x06334ec396a4110ace68be4ff5d1579af2042abebae12632e32fc567bc461ed1](https://goerli.voyager.online/contract/0x06334ec396a4110ace68be4ff5d1579af2042abebae12632e32fc567bc461ed1)|
|[L2 Evaluator](contracts/Evaluator.cairo)|[0x195bcd27328405ef78ddc6c47b2258705dfa3bea21f7e887e66475664b84c5b](https://goerli.voyager.online/contract/0x195bcd27328405ef78ddc6c47b2258705dfa3bea21f7e887e66475664b84c5b)|
|[l2nft](contracts/l2nft.cairo)|[0x03fee3d8ed3c3f139aee59658402f5e1e132caf9bd9d13c6f767024a824f7470](https://goerli.voyager.online/contract/0x03fee3d8ed3c3f139aee59658402f5e1e132caf9bd9d13c6f767024a824f7470)|
|[L1 Dummy token](contracts/L1/DummyToken.sol)|[0x0232CB90523F181Ab4990Eb078Cf890F065eC395](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395)|
|[L1 Messaging NFT](contracts/L1/MessagingNft.sol)|[0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E)|
​|[L1 Evaluator](contracts/L1/Evaluator.sol)|[0x8055d587A447AE186d1589F7AAaF90CaCCc30179](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179)|
