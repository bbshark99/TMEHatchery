
// Contracts
const TAMAG = artifacts.require("TAMAG");
const TMEHatchery = artifacts.require("TMEHatchery");
const TMETraitOracle = artifacts.require("TMETraitOracle");
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

    const tamag = await TAMAG.deployed(); //at("0xa6D82Fc1f99A868EaaB5c935fe7ba9c9e962040E"); //for miannet

    const hatchery = await TMEHatchery.deployed();
    const oracle = await TMETraitOracle.deployed();
    
    console.log("tamag", tamag.address);
    console.log("hatchery", hatchery.address);
    console.log("oracle", oracle.address);
    let successRate = await hatchery.HATCH_THRESHOLD();
    console.log(successRate.toString())

  }
  catch(error) {
    console.log(error)
  }

  callback()
}