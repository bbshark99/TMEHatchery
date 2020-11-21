const TAMAG = artifacts.require('./TAMAG.sol')
require('dotenv').config()

module.exports = (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TAMAG...')

  console.log('deploying from:' + deployAddress)


  deployer.deploy(TAMAG, {
    from: deployAddress
  })
}
