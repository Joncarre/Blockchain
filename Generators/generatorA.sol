// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

/// @title 
/// @author J. Carrero
contract generatorA {
    
    // Researcher information
    struct Researcher {
        string name;
        bool registered;
        Linked[] set;
    }
    mapping(address => Researcher) researchers;
    
    // Instance information
    struct Instance {
        uint id;
        string instance;
        string solution;
        string date;
    }
    Linked[] linkeds;
    
    // Relation between researches and their instances
    struct Linked {
        uint id;
        uint time;
    }
    Instance[] instances;
    
    // General stuffs
    address owner;
    uint[] symbols;  
    uint p;
    uint q;
    uint nonce;
    uint clausesLength;
    
    /// @notice Main constructor
    constructor(uint _p, uint _q) public {
        p = _p;
        q = _q;
        owner = msg.sender;
        nonce = 0;
        clausesLength = 3;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this.");
        _;
    }
    
    modifier notOwner() {
        require(msg.sender != owner, "Owner can't participate.");
        _;
    }
    
    modifier notRegistered() {
        require(!isRegistered(msg.sender), "Agent is already registered.");
        _;
    }
    
    /// @notice Register a new researcher 
    function regResearcher(string memory _name) notOwner notRegistered public {
        Researcher memory newResearcher = Researcher(_name, true);
        researchers.push(newResearcher);
    }
    
    /// @notice Generates a new researcher 
    function createInstance() onlyOwner public view {
        string memory lambda = "";
        string memory solution = "";
        symbols.push(symbols.length);
        
        for(uint i = 0; i < 2; i++){
        // NOTA: Cambiar la condición por número random
            if(i < 1) {
                symbols.push(symbols.length);
            }
            lambda += createClause() + " ∧ ";
        }
        Instance memory newInstance = Instance(Instance.length, lambda, solution, now);
    }
    
    function createClause() internal pure returns (string memory) {
        string memory c = "(";
        for(uint i = 0; i < clausesLength; i++){
            // NOTA: cambiar esto por probabilidad 50%
            if(true){
                c += symbols[random(symbols.length)];
            }else{
                c += "¬" + symbols[random(symbols.length)]; 
            }
            c += " ∨ ";
        }
        c += ")";
        return c;
    }
    
    function getResearcherInstances(address _direction) public pure returns (Linked[] memory) {
        return researchers[_direction].set;
    }
    
    function isRegistered(address _direction) public pure returns (bool) {
        return researchers[_direction].registered;
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
}
