const TMEHatchery = artifacts.require('./TMEHatchery.sol')
const TAMAG = artifacts.require('./TAMAG.sol')
const TMEStats = artifacts.require('./TMEStats.sol')
// const TMETraitOracle = artifacts.require('./TMETraitOracle.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TMEStats...')

  console.log('deploying from:' + deployAddress)
  const tmeHatchery = await TMEHatchery.deployed();
  // const tme = "0x6E742E29395Cf5736c358538f0f1372AB3dFE731"; // mainnet
  const tme = "0x871d72C888B7d92686E01e48F6F06FFB11EEe9B5"; //rinkeby
  const tamag = await TAMAG.deployed();

  await deployer.deploy(TMEStats, tmeHatchery.address, tme, tamag.address, {
    from: deployAddress
  })


}
