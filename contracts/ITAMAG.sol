pragma solidity ^0.6.0;

interface ITAMAG {
    function hatch(address player, uint256 trait, string memory tokenURI) external returns (uint256);
}