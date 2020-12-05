const TMEHatchery = artifacts.require('./TMEHatchery.sol')
const TMETraitOracle2 = artifacts.require('./TMETraitOracle2.sol')
const TAMAG = artifacts.require('./TAMAG.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  let deployAddress = accounts[0] // by convention

  console.log('setup from:' + deployAddress)
  // const tmeHatchery = await TMEHatchery.at("0x4A5783F706782475f9EF2089D44fdf76F38e7D60"); //mainnet
  const tmeHatchery = await TMEHatchery.deployed();
  const tmeTraitOracle2 = await TMETraitOracle2.deployed();
  // const tamag = await TAMAG.at("0xa6D82Fc1f99A868EaaB5c935fe7ba9c9e962040E"); //mainnet
  const tamag = await TAMAG.deployed();

  await tmeHatchery.setTraitOracle(tmeTraitOracle2.address);
  await tamag.setHatchery(tmeHatchery.address);

}
