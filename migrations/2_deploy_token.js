const TAMAG = artifacts.require('./TAMAG.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TAMAG...')
  const signer = "0x8EF9A1A12e0B7E92f11d112f51Ae1054Ddc0E37D"; //tamasigner

  console.log('deploying from:' + deployAddress)


  await deployer.deploy(TAMAG, signer, {
    from: deployAddress
  })
}
