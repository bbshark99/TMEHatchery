pragma solidity >=0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./ITMETraitSource.sol";

// random oracle following cryptokitties GeneScience contract
contract TMETraitOracle is Ownable{
    using SafeMath for uint256;

    ITMETraitSource public traitSource;

    uint256 internal constant maskLast8Bits = uint256(0xff);
    uint256 internal constant maskFirst248Bits = uint256(~0xff);
    

    constructor(address _traitSource) public {
        traitSource = ITMETraitSource(_traitSource);
    }

    function getRandomN(uint256 targetBlock, address owner, uint256 startTimestamp, uint256 hatchId) public view returns (uint256){
        require(block.number > targetBlock);

        uint256 randomN = uint256(blockhash(targetBlock));

        if (randomN == 0) {
            targetBlock = (block.number & maskFirst248Bits) + (targetBlock & maskLast8Bits);
            if (targetBlock >= block.number) targetBlock -= 256;
            randomN = uint256(blockhash(targetBlock));
        }
        // generate 256 bits of random, using as much entropy as we can from
        // sources that can't change between calls.
        randomN = uint256(keccak256(abi.encodePacked(randomN, uint256(owner), startTimestamp, hatchId)));

        return randomN;
    }

}