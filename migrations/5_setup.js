const TMEHatchery = artifacts.require('./TMEHatchery.sol')
const TMETraitOracle = artifacts.require('./TMETraitOracle.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  let deployAddress = accounts[0] // by convention

  console.log('deploying from:' + deployAddress)
  const tmeHatchery = await TMEHatchery.deployed();
  const tmeTraitOracle = await TMETraitOracle.deployed();

  await tmeHatchery.setTraitOracle(tmeTraitOracle.address);
  
}
