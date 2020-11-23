const TMEHatchery = artifacts.require('./TMEHatchery.sol')
// const TMETraitOracle = artifacts.require('./TMETraitOracle.sol')
const TMETraitOracle2 = artifacts.require('./TMETraitOracle2.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TMETraitOracle2...')

  console.log('deploying from:' + deployAddress)
  const tmeHatchery = await TMEHatchery.deployed();
  const seed = Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
  console.log("Random seed: ", seed);
  await deployer.deploy(TMETraitOracle2, tmeHatchery.address, seed, {
    from: deployAddress
  })
}
