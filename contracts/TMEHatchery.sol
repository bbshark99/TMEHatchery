pragma solidity ^0.6.0;
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./TMEAccessControl.sol";
import "./ITAMAG.sol";
import "./TMETraitSource.sol";
import "./ITMETraitOracle.sol";

// main staking contract
contract TMEHatchery is Ownable, ReentrancyGuard, TMEAccessControl, TMETraitSource{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address signerAddress;

    ITAMAG public tamag;
    IERC20 public tme;
    ITMETraitOracle public traitOracle;

    struct Incubation {
        uint256 id;
        uint256 startBlock;
        uint256 targetBlock;
        address owner;
        uint256 startTimestamp;
        uint256 endTimestamp;
        bool hatched;
        bool failed;
        uint256 traits;
    }

    Incubation[] public incubations;
    mapping(address => uint8) public ownerToNumIncubations;
    mapping(address => uint8) public ownerToNumActiveIncubations;
    mapping(address => uint256[]) public ownerToIds;
    uint256 public maxActiveIncubationsPerUser = 2;

    uint256 public inbucateDurationInSecs = 24 * 3600;
    uint256 public blocksTilColor = 2880; // 12h / 15secs per block
    uint256 public secsPerBlock = 15;

    uint8 public SUCCESS_BIT_WIDTH = 8;
    uint8 public SUCCESS_OFFSET = 0;
    // 5% of 256 = 12.8, round down to 12.
    // 0 - 11 -> hatching failed.
    // exact failure chance = 12/256 = 4.68 percent
    // 12 - 255 inclusive = success
    // 0-11 inclusive = fail
    uint8 public HATCH_THRESHOLD = 12;

    uint256 tmePerIncubate = 1 ether;
    uint256 tmeReturnOnFail = 0.2 ether;

    address public BURN_ADDRESS = address(1);

    event IncubationStarted(address owner, uint256 startTime, uint256 endTime);
    event FailedHatch(address indexed owner, uint256 hatchId);
    event SuccessfulHatch(address indexed owner, uint256 hatchId);

    constructor(address _tme, address _tamag, address _signerAddress) public {
        tme = IERC20(_tme);
        tamag = ITAMAG(_tamag);
        signerAddress = _signerAddress;

        addTrait("CHEERFULNESS",5,0,true);
        addTrait("ENERGY",5,5,true);
        addTrait("METABOLISM",5,10,true);
    }

    function setSignerAddress(address _signerAddress) public onlyOwner {
        signerAddress = _signerAddress;
    }

    function setTmePerIncubate(uint256 amt) public onlyOwner {
        tmePerIncubate = amt;
    }
    function setTmeReturnOnFail(uint256 amt) public onlyOwner {
        tmeReturnOnFail = amt;
    }

    // always results in incubation of 1 egg.
    function startIncubate() public whenNotPausedIncubate nonReentrant{
        require (tme.balanceOf(msg.sender) >= tmePerIncubate, "Not enough TME");
        require (maxActiveIncubationsPerUser == 0 || ownerToNumActiveIncubations[msg.sender] < maxActiveIncubationsPerUser, "Max active incubations exceed");
        require (tme.transferFrom(address(msg.sender), address(this), tmePerIncubate), "Failed to transfer TME");
        uint256 newId = incubations.length;
        uint256 targetBlock = block.number + inbucateDurationInSecs.div(secsPerBlock) - 20; //buffer to make sure target block is earlier than end timestamp
        uint256 endTime = block.timestamp + inbucateDurationInSecs;
        Incubation memory incubation = Incubation(
            newId,
            block.number,
            targetBlock,
            msg.sender,
            block.timestamp,
            endTime,
            false,
            false,
            0
        );
        traitOracle.registerSeedForIncubation(targetBlock, msg.sender, block.timestamp, newId);

        incubations.push(incubation);
        ownerToNumIncubations[msg.sender] = ownerToNumIncubations[msg.sender] + 1;
        ownerToIds[msg.sender].push(newId);
        ownerToNumActiveIncubations[msg.sender] += 1;

        // require(incubations[newId].id == newId, "Sanity check for using id as arr index");

        emit IncubationStarted(msg.sender, block.timestamp, endTime);
    }

    function getTotalIncubations() public view returns (uint256){
        return incubations.length;
    }
    
    // as only the last 256 blockhashes are available, the resulting randomN changes every 256 blocks;
    function getColorBlockHash(uint256 id) public view returns (uint256) {
        require (id < incubations.length, "invalid id");
        Incubation memory toHatch = incubations[id];
        require (toHatch.startBlock + blocksTilColor < block.number, "wait more blocks");
        uint256 randomN = traitOracle.getColorRandomN(toHatch.startBlock + blocksTilColor, toHatch.id);
        
        return randomN;
    }
    // called by backend to find out hatch result
    // as only the last 256 blockhashes are available, the resulting randomN changes every 256 blocks;
    function getResultOfIncubation(uint256 id) public view returns (bool, uint256){
        require (id < incubations.length, "invalid id");

        Incubation memory toHatch = incubations[id];
        require (toHatch.targetBlock <= block.number, "not reached block");
        uint256 randomN = traitOracle.getRandomN(toHatch.targetBlock, toHatch.id);
        bool success = (_sliceNumber(randomN, SUCCESS_BIT_WIDTH, SUCCESS_OFFSET) >= HATCH_THRESHOLD);
        uint256 randomN2 = uint256(keccak256(abi.encodePacked(randomN)));
        uint256 traits = getTraitsFromRandom(randomN2);

        return (success, traits);
    }
    // 5 10 20 40 60 80
    // function getHatchThresholdPenalized(uint targetBlock) public view returns (uint256){
    //     require (targetBlock <= block.number, "not reached target block yet");
    //     uint256 diff = block.number.sub(targetBlock);
    //     // find number of 256 cycles that have passed.
    //     uint256 threshold = uint256(HATCH_THRESHOLD).mul(1 + (diff >> 8));
    //     if (threshold > 255){
    //         threshold = 255;
    //     }
    //     return threshold;
    // }

    function getSuccessIncubation(uint256 id) public view returns (bool, uint256){
        require (id < incubations.length, "invalid id");

        Incubation memory toHatch = incubations[id];
        require (toHatch.targetBlock <= block.number, "not reached block");
        uint256 randomN = traitOracle.getRandomN(toHatch.targetBlock, toHatch.id);
        bool success = (_sliceNumber(randomN, SUCCESS_BIT_WIDTH, SUCCESS_OFFSET) >= HATCH_THRESHOLD);

        return (success, randomN);
    }
    // a separate backend function running on the cloud prepares the tamag metadata, uploads on ipfs, and gives the tokenURI
    // authenticity of tokenURI is ensure with the v,r,s produced from the backend function
    function hatchAndClaim(uint256 id, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) public whenNotPausedHatch nonReentrant{

        // make a hash = sha(id,tokenURI)
        // make sure hash is the content in the v,r,s signature.
        require (id < incubations.length, "invalid id");
        Incubation memory toHatch = incubations[id];
        require (toHatch.owner == msg.sender, "Only owner can call hatch");
        require (!toHatch.hatched, "Baby already hatched");
        require (toHatch.endTimestamp < block.timestamp, "Not time");

        (bool success, uint256 randomN) = getSuccessIncubation(toHatch.id);
        toHatch.hatched = true;
        ownerToNumActiveIncubations[toHatch.owner] -= 1;

        if (!success){
            toHatch.failed = true;
            // sanity check that frontend got same success result;
            // require (v==0 && r==0 && s==0, "Sanity check failed");
            emit FailedHatch(toHatch.owner, toHatch.id);
            incubations[id] = toHatch;
            if (tmeReturnOnFail > 0){
                tme.safeTransfer(toHatch.owner, tmeReturnOnFail);
            }
            tme.safeTransfer(BURN_ADDRESS, tmePerIncubate.sub(tmeReturnOnFail));

        } else {
            toHatch.failed = false;
            emit SuccessfulHatch(toHatch.owner, toHatch.id);
            tme.safeTransfer(BURN_ADDRESS, tmePerIncubate);

            uint256 randomN2 = uint256(keccak256(abi.encodePacked(randomN)));
            uint256 traits = getTraitsFromRandom(randomN2);
            toHatch.traits = traits;

            bytes32 hashInSignature = prefixed(keccak256(abi.encodePacked(toHatch.id,tokenURI)));
            address signer = ecrecover(hashInSignature, v, r, s);
            require(signer == signerAddress, "Msg needs to be signed by valid signer!");

            tamag.hatch(
                toHatch.owner,
                toHatch.traits,
                tokenURI
            );
            incubations[id] = toHatch;
        }

    }

    // assumes hash is always 32 bytes long as it is a keccak output
    function prefixed(bytes32 myHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", myHash));
    }

    function getTraitsFromRandom(uint256 randomN) public view returns (uint256) {
        // assumes traits are deconflicted in terms of positioning!
        uint256 mask = 0;
        for (uint16 i = 0; i < getNumTraits(); i++){
            mask |= uint256((2**uint256(traits[i].bitWidth)) - 1) << traits[i].offset;
        }
        return randomN & mask;
    }

    /// @dev given a number get a slice of any bits, at certain offset
    /// @param _n a number to be sliced
    /// @param _nbits how many bits long is the new number
    /// @param _offset how many bits to skip
    function _sliceNumber(uint256 _n, uint8 _nbits, uint8 _offset) private pure returns (uint8) {
        // mask is made by shifting left an offset number of times
        uint256 mask = uint256((2**uint256(_nbits)) - 1) << _offset;
        // AND n with mask, and trim to max of _nbits bits
        return uint8((_n & mask) >> _offset);
    }

    /* setters */
    function setIncubateDurationInSecs(uint256 secs) public onlyOwner{
        inbucateDurationInSecs = secs;
    }

    function setSecsPerBlock(uint256 secs) public onlyOwner{
        secsPerBlock = secs;
    }

    function setBlocksTilColor(uint256 num) public onlyOwner{
        blocksTilColor = num;
    }

    function setSuccessInfo(uint8 bitWidth, uint8 offset) public onlyOwner{
        SUCCESS_BIT_WIDTH = bitWidth;
        SUCCESS_OFFSET = offset;
    }

    function setHatchThreshold(uint8 threshold) public onlyOwner{
        HATCH_THRESHOLD = threshold;
    }
    
    function setTME(address _a) public onlyOwner {
        tme = IERC20(_a);
    }
    function setTAMAG(address _a) public onlyOwner {
        tamag = ITAMAG(_a);
    }
    function setTraitOracle(address _a) public onlyOwner {
        traitOracle = ITMETraitOracle(_a);
    }
    function setMaxActiveIncubationsPerUser(uint256 num) public onlyOwner {
        maxActiveIncubationsPerUser = num;
    }
    // emergency function so things don't get stuck inside contract
    function emergencyWithdrawEth() public onlyOwner {
        uint256 b = address(this).balance;
        address payable a = payable(owner());
        a.transfer(b);
    }
    function emergencyWithdrawTME() public onlyOwner {
        uint256 tokenBalance = tme.balanceOf(address(this));
        tme.safeTransfer(owner(), tokenBalance);
    }
    
}