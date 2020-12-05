
// Contracts
const TMEStats = artifacts.require("TMEStats");
// const TMEHatchery = artifacts.require("TMEHatchery");
// const TMETraitOracle2 = artifacts.require("TMETraitOracle2");
// Utils
const ether = (n) => {
  return new web3.utils.BN(
    web3.utils.toWei(n.toString(), 'ether')
  )
}

module.exports = async function(callback) {
  try {
    // Fetch accounts from wallet - these are unlocked
    const accounts = await web3.eth.getAccounts()
    const tmeStats = await TMEStats.deployed();
    // let test0 = await tmeStats.getHatcheryTotalIncubations();
    // console.log(test0.toString())

    // let test1 = await tmeStats.getHatcheryIncubation(0);
    // console.log(test1[0].toString(), test1[1].toString());

    let test = await tmeStats.getStats(0,60);
    console.log(test[0].toString(),test[1].toString(),test[2].toString())
    // const hatchery = await TMEHatchery.deployed();
    // const oracle = await TMETraitOracle2.deployed();
  }
  catch(error) {
    console.log(error)
  }

  callback()
}