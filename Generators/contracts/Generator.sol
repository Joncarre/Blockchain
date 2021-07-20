// SPDX-License-Identifier: MIT
// Generales:
// - Dame la información del usuario: que instancias tiene, cuantas veces ha pedido instancias, información de su ORCID

pragma solidity >=0.4.22 <0.8.0;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/master/evm-contracts/src/v0.6/VRFConsumerBase.sol";

/// @title 
/// @author J. Carrero
contract generator is VRFConsumerBase {
    // Researcher information
    struct Researcher {
        string name;
        bool registered;
        string solution;
    }
    mapping(uint => Researcher) researchers;
    
    // Instance information
    struct Instance {
        uint id;
        string instance;
        uint date;
    }
    Instance[] instances;
    
    // Relation between researches and their instances
    struct Linked {
        uint[] idInstances;
    }
    mapping(uint => Linked) links;
    
    // General variables
    address owner;
    uint nonce;
    
    // VRF variables
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    
    // MAX-3SAT variables
    uint[] symbols;  
    uint p;
    uint q;
    uint clausesLength;
    
    /// @notice Main constructor
    constructor(uint _p, uint _q) 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public {
        
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        p = _p;
        q = _q;
        owner = msg.sender;
        nonce = 0;
        clausesLength = 3;
    }
    
    // ---------------------------------- General functions ----------------------------------
    
    /// @notice Registers a new Researcher 
    function regResearcher(string memory _name, string memory _solution, uint _orcid) public {
        require(!researchers[_orcid].registered, "Researcher is already registered");
        Researcher memory newResearcher = Researcher(_name, true, _solution);
        researchers[_orcid] = newResearcher;
    }
    
    /// @notice Gets Researcher information
    function getResearcherInformation(uint _orcid) public view returns (uint[] memory) {
        require(researchers[_orcid].registered, "You must be registered");
        return (links[_orcid].idInstances);
    }
    
    /// @notice Generates a random number within an interval
    /// @param _interval upper index of the (open) interval of the random value
    /// @dev now, msg.sender and nonce are the timestamp of the block, who made the call and an incremental number respectively
    /// @return The number generated
    function random(uint _interval) internal returns (uint) {
        uint randNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % _interval;
        nonce++;
        return randNumber;
    }
   
    // ---------------------------------- VRF functions ----------------------------------
    
    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK, fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness.mod(100);
    }
    
    // ------------------------------- MAX-3SAT functions --------------------------------
    
    /// @notice Generates a new Instance 
    function createInstance() public {
        string memory fi = ""; // empty initialitation
        symbols.push(symbols.length);
        for(uint i = 0; i < 2; i++)
            if(random(100) < p) // [0, 99] < p
                symbols.push(symbols.length);  
        
        fi = conca(fi, createClause(), "", "");
        while(random(100) < q){ // [0, 99] < q
            for(uint i = 0; i < 3; i++)
                if(random(100) < p) // [0, 99] < p
                    symbols.push(symbols.length);  
            
            fi = conca(fi, " ∧ ", createClause(), ""); 
        }
        Instance memory newInstance = Instance(instances.length, fi, now);
        instances.push(newInstance);
    }
    
    // @notice Creates a new clause
    function createClause() internal returns (string memory) {
        string memory c = "(";
        for(uint i = 0; i < clausesLength; i++){
            if(random(100) < 50) // [0, 9] < 5 => 50% probability
                c = conca(c, "x", intToString(symbols[random(symbols.length)]), "");
            else
                c = conca(c, "¬", "x", intToString(symbols[random(symbols.length)]));
            // We need to add a new symbol in every iteration except for the last one
            if(i < clausesLength-1)
                c = conca(c, " ∨ ", "", "");
        }
        c = conca(c, ")", "", "");
        return c;
    }

    function conca(string memory s1, string memory s2, string memory s3, string memory s4) internal pure returns (string memory) {
        return string(abi.encodePacked(s1, s2, s3, s4));
    }
   
    // -------------------------------- Support functions --------------------------------
    
    function getSymbolArray() public view returns (uint[] memory){
       return symbols;
    }
   
    function getInstance(uint _index) public view returns (uint, string memory, uint){
        return (instances[_index].id, instances[_index].instance, instances[_index].date);
    }
    
    function intToString(uint _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}