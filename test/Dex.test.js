const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dex", function () {

  before(async function() {
    this.Dex = await ethers.getContractFactory('Dex');
  });

  beforeEach(async function () {
    this.Dex = await this.Dex.deploy();
    await this.Dex.deployed();
  });

  it("Should return the new address once it's changed", async function () {
    const [owner] = await ethers.getSigners();

    const Dex = await ethers.getContractFactory("Dex");
    
    const dex = await Dex.deploy();

    await dex.deployed();

    // expect(await Ddex.add()).to.equal("Hello, world!");
    console.log('deployed address', dex.address);    
  });

  
});
