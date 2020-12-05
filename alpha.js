
// Contracts
const TAMAG = artifacts.require("TAMAG");
const TMEHatchery = artifacts.require("TMEHatchery");
const TMETraitOracle2 = artifacts.require("TMETraitOracle2");

const BigNumber = require("bignumber.js");

// Utils
const ether = (n) => {
  return new web3.utils.BN(
    web3.utils.toWei(n.toString(), 'ether')
  )
}

const getMod256 = (n) => {
  return new web3.utils.BN(n).modulo(256);
}
module.exports = async function(callback) {
  try {
    // Fetch accounts from wallet - these are unlocked
    const accounts = await web3.eth.getAccounts()

    // const tamag = await TAMAG.deployed(); //at("0xa6D82Fc1f99A868EaaB5c935fe7ba9c9e962040E"); //for miannet

    const hatchery = await TMEHatchery.deployed();
    const oracle = await TMETraitOracle2.deployed();
    await hatchery.unpauseIncubate();

    // console.log("tamag", tamag.address);
    // console.log("hatchery", hatchery.address);
    // console.log("oracle", oracle.address);

    // await hatchery.setIncubateDurationInSecs(120);
    // await hatchery.setBlocksTilColor(4);
    callback()
    return;
    // let v = await oracle.getRandomN(123, 0);
    // console.log(v.toString())


    
    let ia = [38, 39, 44, 49, 50]
    for (let i of ia){
      let incub = await hatchery.incubations(i);
      let v1 = await oracle.getRandomN(incub.targetBlock, incub.id);
      console.log(new BigNumber(v1).modulo(256).toString())
      // let v2 = await oracle.getRandomN(11321174, 5);
      // console.log(v1.toString());
      // console.log(v2.toString());
    }
    // console.log(v1.toString())
    // let seed = await oracle.getSeed();
    // console.log("Seed", seed.toString())
  }
  catch(error) {
    console.log(error)
  }

  callback()
}