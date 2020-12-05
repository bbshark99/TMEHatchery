pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITAMAG is IERC721{
    function hatch(address player, uint256 trait, string memory tokenURI) external returns (uint256);
    function getTrait(uint256 tokenId) external returns (uint256);
    function setMetadataByUser(uint256 tokenId, uint256 newTraits, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) external;

    function setHatchery(address a) external;
    function setSignerAddress(address a) external;

    function idToNounce(uint256) external returns (uint256);
    function burn(uint256 tokenId) external;
    
}