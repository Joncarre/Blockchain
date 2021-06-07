// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

/// @title 
/// @author J. Carrero
contract generatorA {
    
    // Researcher information
    struct Researcher {
        string name;
        bool registered;
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
        address idResearcher;
        uint idInstance;
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
        require(researchers[msg.sender].registered == false, "Researcher is already registered.");
        _;
    }
    
    /// @notice Register a new researcher 
    function regResearcher(string memory _name) notOwner notRegistered public {
        Researcher memory newResearcher = Researcher(_name, true);
        researchers[msg.sender] = newResearcher;
    }
    
    /// @notice Generates a new researcher 
    function createInstance() onlyOwner public {
        symbols.push(symbols.length);
        
    }
    
    function createClause() internal returns (string memory) {
        uint[] memory choosen = new uint[](3);
        bool[] memory sign = new bool[](3);
        for(uint i = 0; i < clausesLength; i++){
            // We choose a symbol
            choosen[i] = symbols[random(symbols.length)];
            // We choose its sign
            if(random(5) < 10){ // 50% probability
                sign[i] = true;
            }else{
                sign[i] = false; 
            }
        }
        // Finally, we build the clause
        string memory c = "";
        
        return c;
    }
    
    /*function getResearcherInstances(address _direction) public pure returns (Linked[] memory) {
        return researchers[_direction].set;
    }*/
    
    
    /// @notice Generates a random number within an interval
    /// @param _interval upper index of the (open) interval of the random value
    /// @dev now, msg.sender and nonce are the timestamp of the block, who made the call and an incremental number respectively
    /// @return The number generated
    function random(uint _interval) internal returns (uint) {
        uint randNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % _interval;
        nonce++;
        return randNumber;
    }
    
    function concatenate(string memory s1, string memory s2) public pure returns (string memory) {
        return string(abi.encodePacked(s1, s2));
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
   
   // -------------------------------- test functions ------------------------------------
   function getArray() public view returns (uint[] memory){
       return symbols;
   }
}
