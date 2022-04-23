// const { artifacts } = require("hardhat");

// var Dex = require("Dex/build/contracts/Dex.json");
const Dai = artifacts.require("DAI"); // 0x64039888Caee025cD6f56f99DE6F5Ce8caC59283
const Dex = artifacts.require('Dex'); //  0x14058DEe95e7558E8bcce038c0aF230e5dC3724e
module.exports = function (deployer) {
  deployer.deploy(Dex);
  deployer.deploy(Dai);
};
