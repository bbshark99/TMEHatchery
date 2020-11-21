pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TAMAGProperties {
    mapping (uint256 => uint256) traits;
    // mapping (uint256 => string) tamagNames;

}

contract TAMAG is ERC721, TAMAGProperties, ERC721Burnable, Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address hatchery;

    modifier onlyHatchery() {
        require((hatchery == address(0)) || (msg.sender == hatchery), "Only hatchery");
        _;
    }
    

    function setHatchery(address a) public onlyOwner {
        hatchery = a;
    }
    constructor() public ERC721("TAMAG NiftyGotchi", "TAMAG") TAMAGProperties() {
        // _setBaseURI("my base url");
    }
    function create(uint256 trait, string memory tokenURI) public onlyOwner {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        traits[newItemId] = trait;
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
    }

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
    // function setTamagName(uint256 tokenId, string memory name) public{
    //     require(ownerOf(tokenId) == msg.sender, "Only current owner of NFT can change name");
    //     tamagNames[tokenId] = name;
    // }
    // function getTamagName(uint256 tokenId) public view returns (string memory) {
    //     return tamagNames[tokenId];
    // }

    function getTrait(uint256 tokenId) public view returns (uint256){
        return traits[tokenId];
    }
    function setTrait(uint256 tokenId, uint256 _trait) public onlyOwner{
        require(_exists(tokenId), "id does not exist");
        require(ownerOf(tokenId) == msg.sender, "Only owner can change trait");
        traits[tokenId] = _trait;
    }
    function setTokenURI(uint256 tokenId, string memory tokenURI) public onlyOwner{
        _setTokenURI(tokenId, tokenURI);
    }

    function setTokenURIByUser(uint256 tokenId, string memory tokenURI, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public {
        require(ownerOf(tokenId) == msg.sender, "Only owner can change tokenURI");

        bytes32 testHash = keccak256(abi.encodePacked(tokenURI));
        require(testHash == msgHash, "Hash of tokenURI don't match msgHash");

        address signer = ecrecover(msgHash, v, r, s);
        require(signer == owner(), "Msg needs to be signed by dev!");

        setTokenURI(tokenId, tokenURI);

    }

}