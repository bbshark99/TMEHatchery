pragma solidity >=0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./ITMETraitSource.sol";

contract TMETraitOracle2 is Ownable{

    mapping(uint256 => uint256) private incubationToSeed;
    uint256 private seed;
    address public hatchery;
    uint256 internal constant maskLast8Bits = uint256(0xff);
    event SeedChanged();

    modifier onlyHatchery() {
        require(_msgSender() == owner() || _msgSender() == hatchery, "Only owner or hatchery!");
        _;
    }

    constructor(address _hatchery, uint256 _seed) public {
        seed = _seed;
        hatchery = _hatchery;
    }

    function setSeed(uint256 _seed) public onlyOwner {
        seed = _seed;
    }
    function getSeed() public view onlyOwner returns (uint256) {
        return seed;
    }
    
    function registerSeedForIncubation(uint256 targetBlock, address incubOwner, uint256 startTimestamp, uint256 incubationId) public onlyHatchery {
        uint256 randomN = uint256(keccak256(abi.encodePacked(targetBlock, uint256(incubOwner), startTimestamp, incubationId, seed)));
        incubationToSeed[incubationId] = randomN;

        if (randomN & maskLast8Bits > 127){
            seed = uint256(keccak256(abi.encodePacked(randomN, blockhash(block.number - 1))));
            emit SeedChanged();
        }
    }
    
    function getRandomN(uint256 targetBlock, uint256 hatchId) public onlyHatchery view returns (uint256){
        require(block.number > targetBlock);
        return incubationToSeed[hatchId];
    }
    function getColorRandomN(uint256 targetBlock, uint256 hatchId) public onlyHatchery view returns (uint256){
        require(block.number > targetBlock);
        return uint256(keccak256(abi.encodePacked(targetBlock,incubationToSeed[hatchId])));
    }


}