pragma solidity >=0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ITMEHatchery.sol";
import "./ITAMAG.sol";


contract TMEStats is Ownable{

    ITAMAG tamag;
    ITMEHatchery hatchery;
    IERC20 tme;

    constructor(address _hatchery, address _tme, address _tamag) public {
        hatchery = ITMEHatchery(_hatchery);
        tme = IERC20(_tme);
        tamag = ITAMAG(_tamag);
    }
    function getHatcheryTotalIncubations() public view returns (uint256) {
        return hatchery.getTotalIncubations();
    }
    function getHatcheryIncubation(uint256 i) public view returns (bool, bool){
        (,,,,,,bool hatched, bool failed,) = hatchery.incubations(i); 
        return (hatched, failed);
    }
    function getStats(uint256 start, uint256 end) public view returns (uint256, uint256, uint256) {
        // uint256 numIncubations = hatchery.getTotalIncubations();
        require(end <= hatchery.getTotalIncubations(), "invalid index");
        uint256 success = 0;
        uint256 fail = 0;
        uint256 inprogress = 0;
        for (uint256 i = start; i < end; i ++){
            (,,,,,,bool hatched, bool failed,) = hatchery.incubations(i); 
            if (hatched && !failed){
                success += 1;
            } else if (hatched && failed){
                fail += 1;
            } else if (!hatched){
                inprogress += 1;
            }
        }
        return (success, fail, inprogress);
    }


}