
const { expectRevert } = require('@openzeppelin/test-helpers');
let Dai = artifacts.require('tokens/DAI.sol');
let Bat = artifacts.require('tokens/BAT.sol');
let Xrp = artifacts.require('tokens/XRP.sol');
let Shib = artifacts.require('tokens/SHIB.sol');
let Dex = artifacts.require('Dex.sol');

const SIDE = {
  BUY: 0,
  SELL: 1
};

contract('Dex', (accounts) => {
  let dai, bat, xrp, shib, dex;
  const [trader1, trader2] = [accounts[1], accounts[2]];
  const [DAI, BAT, XRP, SHIB] = ['DAI', 'BAT', 'XRP', 'SHIB']
    .map(ticker => web3.utils.fromAscii(ticker));

    before(async () => {
        dex = await Dex.deployed();
    })
  beforeEach(async() => {
    ([dai, bat, xrp, shib] = await Promise.all([
      Dai.new(), 
      Bat.new(), 
      Xrp.new(), 
      Shib.new()
    ]));
    dex = await Dex.new();
    await Promise.all([
      dex.addToken(DAI, dai.address),
      dex.addToken(BAT, bat.address),
      dex.addToken(XRP, xrp.address),
      dex.addToken(SHIB, shib.address),
    //   dex.addToken(SHIB, shib.address)
    ]);
    // console.log(`DeXchange => ${dex.address}`)
    console.log(`DAI address => ${dai.address}`)
    console.log(`BAT address => ${bat.address}`)
    console.log(`XRP address => ${xrp.address}`)
    console.log(`SHIB address => ${shib.address}`)

    const amount = web3.utils.toWei('1000');
    // const coinAdd = Dex.address;
    const seedTokenBalance = async (token, trader) => {
      await token.faucet(trader, amount)
      await token.approve(
        dex.address, 
        amount, 
        {from: trader}
      );
    };
    
    await Promise.all(
      [dai, bat, xrp, shib].map(
        token => seedTokenBalance(token, trader1) 
      )
    );
    await Promise.all(
      [dai, bat, xrp, shib].map(
        token => seedTokenBalance(token, trader2) 
      )
    );
  });
//   console.log(`DAI address => ${getAddress(dai)}`);
// catch(e){
//     console.log('error =>',e);
// }


   it('should deposit tokens', async () => {
    const amount = web3.utils.toWei('100');
    
    await dex.deposit(
      amount,
      DAI,
      {from: trader1}
    );

    const balance = await dex.traderBalances(trader1, DAI);
    assert(balance.toString() === amount);
  });

});
