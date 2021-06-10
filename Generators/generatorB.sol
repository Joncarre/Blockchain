// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

/// @title 
/// @author J. Carrero
contract generatorB {
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
    }
    Instance[] instances;
    
    // Relation between researches and their instances
    struct Linked {
        uint[] idInstances;
        uint date;
    }
    mapping(address => Linked) links;
    
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
        require(!researchers[msg.sender].registered, "Researcher is already registered.");
        _;
    }
    
    modifier Registered() {
        require(researchers[msg.sender].registered, "You must be registered");
        _;
    }
    
    /// @notice Registers a new Researcher 
    function regResearcher(string memory _name) notOwner notRegistered public {
        Researcher memory newResearcher = Researcher(_name, true);
        researchers[msg.sender] = newResearcher;
    }
    
    /// @notice Generates a new Instance 
    function createInstance() onlyOwner public {
        string memory fi = ""; // empty initialitation
        symbols.push(symbols.length);
        uint num = 0;
        while(random(100) < q) // [0, 99] < q
            num++;
        
        for(uint i = 0; i < (3*num)-1; i++)
            if(random(100) < p) // [0, 99] < p
                symbols.push(symbols.length);  
        
        for(uint i = 0; i < num; i++)
            fi = conca3(fi, " ∧ ", createClause()); 
        
        Instance memory newInstance = Instance(instances.length, fi, "");
        instances.push(newInstance);
    }
    
    // @notice Creates a new clause
    function createClause() internal returns (string memory) {
        string memory c = "(";
        for(uint i = 0; i < clausesLength; i++){
            if(random(100) < 50) // [0, 9] < 5 => 50% probability
                c = conca3(c, "x", intToString(symbols[random(symbols.length)]));
            else
                c = conca4(c, "¬", "x", intToString(symbols[random(symbols.length)]));
            // We need to add a new symbol in every iteration except for the last one
            if(i < clausesLength-1)
                c = conca2(c, " ∨ ");
        }
        c = conca2(c, ")");
        return c;
    }
    
    function getSetInstance(uint _size) Registered public {
        uint[] memory set = new uint[](_size);
        for(uint i = 0; i < _size; i++)
            set[i] = random(instances.length);
        Linked memory newLink = Linked(set, now);
        links[msg.sender] = newLink;
    }
    
    function getResearcherInformation(address _address) Registered public view returns (uint[] memory, uint) {
        require(msg.sender == _address, "You can only access your own data");
        return (links[_address].idInstances, links[_address].date);
    }
    
    function setSolution(string memory _solution, uint _id) onlyOwner public {
        require(_id < instances.length && _id >= 0, "Invalid instance index.");
        instances[_id].solution = _solution;
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
   
    function conca2(string memory s1, string memory s2) internal pure returns (string memory) {
        return string(abi.encodePacked(s1, s2));
    }
    
    function conca3(string memory s1, string memory s2, string memory s3) internal pure returns (string memory) {
        return string(abi.encodePacked(s1, s2, s3));
    }
    
    function conca4(string memory s1, string memory s2, string memory s3, string memory s4) internal pure returns (string memory) {
        return string(abi.encodePacked(s1, s2, s3, s4));
    }
   
    // -------------------------------- Support functions --------------------------------
    
    function getArray() onlyOwner public view returns (uint[] memory){
       return symbols;
    }
   
    function getInstance(uint _index) onlyOwner public view returns (uint, string memory, string memory){
        return (instances[_index].id, instances[_index].instance, instances[_index].solution);
    }
}