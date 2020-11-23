const TMEHatchery = artifacts.require('./TMEHatchery.sol')
const TMETraitOracle2 = artifacts.require('./TMETraitOracle2.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  let deployAddress = accounts[0] // by convention

  console.log('deploying from:' + deployAddress)
  const tmeHatchery = await TMEHatchery.deployed();
  const tmeTraitOracle2 = await TMETraitOracle2.deployed();

  await tmeHatchery.setTraitOracle(tmeTraitOracle2.address);
  
}
