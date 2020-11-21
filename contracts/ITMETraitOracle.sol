pragma solidity >=0.6.0;

interface ITMETraitOracle {
    function getRandomN(uint256 targetBlock, address owner, uint256 startTimestamp, uint256 hatchId) external view returns (uint256);
}