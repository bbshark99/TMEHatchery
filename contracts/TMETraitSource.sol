pragma solidity ^0.6.0;
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TMETraitSource is Ownable{
    // using SafeMath for uint256;
    // using SafeMath for uint16;
    using Counters for Counters.Counter;

    struct TraitInfo {
        string name;
        uint8 bitWidth;
        uint8 offset;
        bool active;
    }

    TraitInfo[] public traits;
    Counters.Counter private numTraits;

    event TraitChange(string name, uint8 bitWidth, uint8 offset, bool active);
    event TraitAdded(string name, uint8 bitWidth, uint8 offset, bool active);
    event TraitActivate(uint256 index);
    event TraitDeactivate(uint256 index);

    function getNumTraits() public view returns (uint256){
        return numTraits.current();
    }
    
    // function getTraitAtIndex(uint256 index) public view returns (string memory name, uint8 bitWidth, uint8 offset, bool active){
    //     require(index < numTraits.current(), "invalid index");
    //     return (traits[index].name,
    //         traits[index].bitWidth,
    //         traits[index].offset,
    //         traits[index].active
    //     );
    // }
    function setTrait(uint256 index, string memory name, uint8 bitWidth, uint8 offset, bool active) public onlyOwner {
        require(index < numTraits.current(), "invalid index");
        traits[index].name = name;
        traits[index].bitWidth = bitWidth;
        traits[index].offset = offset;
        traits[index].active = active;
        emit TraitChange(name, bitWidth, offset, active);

    }
    function addTrait(string memory name, uint8 bitWidth, uint8 offset, bool active) public onlyOwner {
        TraitInfo memory t = TraitInfo(name, bitWidth, offset, active);
        traits.push(t);
        numTraits.increment();
        emit TraitAdded(name, bitWidth, offset, active);
    }
    function deactivateTrait(uint256 index) public onlyOwner {
        require(index < numTraits.current(), "invalid index");
        traits[index].active = false;
        emit TraitDeactivate(index);
    }
    function activateTrait(uint256 index) public onlyOwner {
        require(index < numTraits.current(), "invalid index");
        traits[index].active = true;
        emit TraitActivate(index);
    }
    
}