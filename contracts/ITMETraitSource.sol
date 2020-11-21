pragma solidity ^0.6.0;

interface ITMETraitSource {
    function getNumTraits() external view returns (uint256);
    
    function setTrait(uint256 index, string memory name, uint8 bitWidth, uint8 offset, bool active) external;
     
    function addTrait(string memory name, uint8 bitWidth, uint8 offset, bool active) external;
      
    function deactivateTrait(uint256 index) external;
      
    function activateTrait(uint256 index) external;
        
}