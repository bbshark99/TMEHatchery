const TMEHatchery = artifacts.require('./TMEHatchery.sol')
const TAMAG = artifacts.require('./TAMAG.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TMEHatchery...')

  console.log('deploying from:' + deployAddress)
  // const tme = "0x6E742E29395Cf5736c358538f0f1372AB3dFE731"; // mainnet
  const tme = "0x871d72C888B7d92686E01e48F6F06FFB11EEe9B5"; //rinkeby
  const signer = "0x8EF9A1A12e0B7E92f11d112f51Ae1054Ddc0E37D"; //tamasigner
  const tamag = await TAMAG.deployed();

  await deployer.deploy(TMEHatchery, tme, tamag.address, signer, {
    from: deployAddress
  })
}
