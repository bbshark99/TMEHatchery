pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TAMAGProperties {
    mapping (uint256 => uint256) traits;
    mapping (uint256 => uint256) public idToNounce;

}

contract TAMAG is ERC721, TAMAGProperties, ERC721Burnable, Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address public hatchery;
    address public signerAddress;

    modifier onlyHatchery() {
        require((_msgSender() == owner()) || (hatchery == address(0))|| (_msgSender() == hatchery), "Only owner or hatchery");
        _;
}
    
    constructor(address _signerAddress) public ERC721("TAMAG NiftyGotchi", "TAMAG") TAMAGProperties() {
        signerAddress = _signerAddress;
    }

    // function create(uint256 trait, string memory tokenURI) public onlyOwner {
    //     _tokenIds.increment();
    //     uint256 newItemId = _tokenIds.current();
    //     traits[newItemId] = trait;
    //     _mint(msg.sender, newItemId);
    //     _setTokenURI(newItemId, tokenURI);
    // }

    function hatch(address player, uint256 trait, string memory tokenURI)
        public onlyHatchery
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        traits[newItemId] = trait;
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function getTrait(uint256 tokenId) public view returns (uint256){
        return traits[tokenId];
    }
    
    // assumes hash is always 32 bytes long as it is a keccak output
    function prefixed(bytes32 myHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", myHash));
    }

    // requires both owner and dev to participate in this;
    function setMetadataByUser(uint256 tokenId, uint256 newTraits, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) public {
        require(ownerOf(tokenId) == msg.sender, "Only owner can change tokenURI");

        uint256 currNounce = idToNounce[tokenId];

        bytes32 hashInSignature = prefixed(keccak256(abi.encodePacked(currNounce,"_",newTraits,"_",tokenId,"_",tokenURI)));
        address signer = ecrecover(hashInSignature, v, r, s);
        require(signer == signerAddress, "Msg needs to be signed by valid signer!");
        
        idToNounce[tokenId] += 1;

        _setTokenURI(tokenId, tokenURI);
        traits[tokenId] = newTraits;
    }

    function setHatchery(address a) public onlyOwner {
        hatchery = a;
    }
    function setSignerAddress(address a) public onlyOwner {
        signerAddress = a;
    }

}