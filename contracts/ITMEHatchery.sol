pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./TMEAccessControl.sol";
import "./ITMETraitSource.sol";

interface ITMEHatchery is ITMETraitSource{

    function startIncubate() external;
    function getTotalIncubations() external view returns (uint256);
    function getColorBlockHash(uint256 id) external view returns (uint256);

    function getResultOfIncubation(uint256 id) external view returns (bool, uint256);
    function getSuccessIncubation(uint256 id) external view returns (bool, uint256);
    function hatchAndClaim(uint256 id, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) external;
    function getTraitsFromRandom(uint256 randomN) external view returns (uint256);
    function setSignerAddress(address _signerAddress) external;
    function setTmePerIncubate(uint256 amt) external;
    function setTmeReturnOnFail(uint256 amt) external;

    function setIncubateDurationInSecs(uint256 secs) external;
    function setSecsPerBlock(uint256 secs) external;
    function setBlocksTilColor(uint256 num) external;
    function setSuccessInfo(uint8 bitWidth, uint8 offset) external;
    function setHatchThreshold(uint8 threshold) external;
    function setTME(address _a) external;
    function setTAMAG(address _a) external;
    function setTraitOracle(address _a) external;
    function setMaxActiveIncubationsPerUser(uint256 num) external;
    function emergencyWithdrawEth() external;
    function emergencyWithdrawTME() external;

    function incubations(uint256) external view returns (uint256, uint256, uint256, address, uint256, uint256, bool, bool, uint256);


    function pauseIncubate() external;
    function unpauseIncubate() external;
    
}