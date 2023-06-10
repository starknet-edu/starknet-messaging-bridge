// Deploying the TD somewhere
// To verify it on Etherscan:
// npx hardhat verify --network sepolia <address> <constructor arg 1> <constructor arg 2>

const hre = require("hardhat");

async function main() {
  // Deploying contracts
  const Evaluator = await hre.ethers.getContractFactory("Evaluator");

  const evaluator = await Evaluator.deploy("0xde29d060D45901Fb19ED6C6e959EB22d8626708e");

  await evaluator.deployed();
  console.log(
    `Evaluator deployed at ${evaluator.address}`
  );
  // Setting L2 selectors and evaluator
    await evaluator.setL2Evaluator(0x0455c60bbd52b3b57076a0180e7588df61046366ad5a48bc277c974518f837c4);
    // await evaluator.setEx01Selector(0x274ab8abc4e270a94c36e1a54c794cd4dd537eeee371e7188c56ee768c4c0c4);
    // await evaluator.setEx05bSelector(0x12db22b429341580131c6b522a5c9f6332d59b08a0077777b46e2e0d1ea3a92);
    // await evaluator.setGenericValidatorSelector(0x1dc98f1a6c797f34828d0049700af70c9c1d28442d6ae5d2fa1732d773ddf1a);
    // console.log("Finished deploying");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
