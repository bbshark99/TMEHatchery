
// Contracts
const TAMAG = artifacts.require("TAMAG");
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

    

    // const tamag = await TAMAG.at("0xa6D82Fc1f99A868EaaB5c935fe7ba9c9e962040E"); // mainnet
    const tamag = await TAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
    // const hatchery = await TMEHatchery.deployed();
    // const oracle = await TMETraitOracle2.deployed();
    const t = await tamag.tokenURI(1);
    console.log(t);
    callback();
    return;
    console.log("tamag", tamag.address);
    // console.log("hatchery", hatchery.address);
    // console.log("oracle", oracle.address);
    let signer = await tamag.signerAddress();
    console.log("signer",signer)
    // try change NFT meta
    let tokenId = 1;
    let oldUri = await tamag.tokenURI(tokenId);
    console.log('oldUri',oldUri);
    let oldTrait = await tamag.getTrait(tokenId);
    console.log("oldTrait",oldTrait.toString());
    let currNounce = await tamag.idToNounce(tokenId);
    console.log("currNounce", currNounce.toString());
    // callback()
    // return;
    let newUri = "helloworld2";
    let newTrait = 12347;

    let msgHash = web3.utils.soliditySha3(currNounce,"_", newTrait,"_", tokenId,"_", newUri); 
    let signed = web3.eth.accounts.sign(msgHash, "edfe0de50a4a5c4504285a86128c5635f6863cca0c4a9b5e0346b228cba9951e");
    
    signed.v = '0x1b';
    signed.r = '0x31c07fb72bf0daa20eb5f20f23b6fc92083d8fd4758c4cbec154e0248782b829';
    signed.s = '0x7358157277edf719c6e893b840a586a2899bc992a282bd4110f5a68097c2013a';

    console.log("signed", signed)
    let test1 = await tamag.getHashInSignature(tokenId, newTrait, newUri)
    console.log("msgHash", test1)
    let test2 = await tamag.getHashNoPrefix(tokenId, newTrait, newUri)
    console.log("msg", test2)
    let test3 = await tamag.recover(test1,signed.v, signed.r, signed.s);
    console.log("test3", test3)
    let test = await tamag.setMetadataByUser(tokenId, newTrait, newUri, signed.v, signed.r, signed.s)

    console.log(test)

    let postUri = await tamag.tokenURI(tokenId);
    console.log('postUri',postUri);
    let postTrait = await tamag.getTrait(tokenId);
    console.log("postTrait",postTrait);
    let postNounce = await tamag.idToNounce(tokenId);
    console.log("postNounce", postNounce);
  }
  catch(error) {
    console.log(error)
  }

  callback()
}