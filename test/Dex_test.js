const { expect } = require("chai");
const { expectRevert } = require('@openzeppelin/test-helpers');
const { ethers, artifacts, contract, web3 } = require("hardhat");

const Dex = artifacts.require('Dex.sol');
const Dai =  artifacts.require('tokens/DAI.sol');
const Bat = artifacts.require('tokens/BAT.sol');
var Xrp =  artifacts.require('tokens/XRP.sol');
var Shib = artifacts.require('tokens/SHIB.sol');

const Side = {
  BUY : 0,
  SELL : 1
};

contract("Dex", function (accounts) {
  let dai, bat, xrp, shib , dex;
  const [trader1, trader2] = [accounts[1], accounts[2]];
  const [DAI, BAT, XRP, SHIB] = ['DAI', 'BAT', 'XRP', 'SHIB'].map(ticker => web3.utils.fromAscii(ticker));

  before(async function() {
    this.dex = await ethers.getContractFactory('Dex');
    this.bat = await ethers.getContractFactory('BAT');
    this.dai = await ethers.getContractFactory('DAI');
  });

  beforeEach(async function () {
    ([dai, bat, xrp, shib] = await Promise.all([
      Dai.new(),
      Bat.new(),
      Xrp.new(),
      Shib.new()
    ])
    );

   let dex = await this.Dex.new();
    await Promise.all([
      dex.addToken(DAI, dai.address)
    ])
    this.Dex = await this.Dex.deploy();
    await this.Dex.deployed();
  });

  it("Should deposit Token", async () => {
    const amount = web3.utils.toWei('100');
    await dex.deposit(
      amount,
      DAI,
      {from: trader1}
    );

  });

//   // it('should add token' , async function() {
    
//   //   const Dex = await hre.ethers.getContractFactory("Dex");
//   //   var dex = await Dex.deploy();

//   //   const dex = await dex.deployed();
//     // const addtoken = await this.dex.addtoken("BAT", "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0");
//     // const AddToken = await dex.
//   // });

  
});
