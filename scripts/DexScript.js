// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [owner] = await hre.ethers.getSigners();
  const Dex = await hre.ethers.getContractFactory("Dex");
    let Dai = await hre.ethers.getContractFactory('DAI');
    const Bat = await hre.ethers.getContractFactory('BAT');
    const Xrp = await hre.ethers.getContractFactory('XRP');
    const Shib = await hre.ethers.getContractFactory('SHIB');
    // deploying with script
    const dex = await Dex.deploy();
    const dai = await Dai.deploy();
    const bat = await Bat.deploy();
    const xrp = await Xrp.deploy();
    const shib = await Shib.deploy();
    // wait untill deployed
    await dex.deployed();
    await dai.deployed();
    await bat.deployed();
    await xrp.deployed();
    await shib.deployed();

    console.log("Dex deployed to:", dex.address);
    console.log('DAI address => ', dai.address);
    console.log('BAT address => ', bat.address);
    console.log('XRP address => ', xrp.address);
    console.log('SHIB address => ', shib.address);
  
  }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
