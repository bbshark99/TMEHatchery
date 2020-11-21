const TMEHatchery = artifacts.require('./TMEHatchery.sol')
const TMETraitOracle = artifacts.require('./TMETraitOracle.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TMETraitOracle...')

  console.log('deploying from:' + deployAddress)
  const tmeHatchery = await TMEHatchery.deployed();

  await deployer.deploy(TMETraitOracle, tmeHatchery.address, {
    from: deployAddress
  })
}
