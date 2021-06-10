// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

/// @title Egalitarian social welfare in smart contracts
/// @author J. Carrero
contract Algorithm {
    // Agent
    struct Agent {
        uint idAgent;
        address direction;
        uint[] preferences;
    }
    Agent[] agents;
    mapping(address => bool) paid;
    mapping(address => bool) registered;
    
    // Auction
    address payable owner;
    uint endBlock;
    uint fee;
    uint registrations = 10; // Limit of participants
    uint public amount; // Ether to pay the gas
    
    // Invididual
    struct Individual {
        uint fitness;
        uint[] genes;
    }
    Individual[] population;
    uint geneLength;
    
    // Algorithm
    uint crossoverRate;
    uint mutationRate;
    uint elitism;
    uint nonce;
    
    /// @notice Main constructor
    constructor(uint _elitism, uint _crossoverRate, uint _mutationRate, uint _duration, uint _fee) public {
        elitism = _elitism;
        crossoverRate = _crossoverRate;
        mutationRate = _mutationRate;
        geneLength = 5;
        endBlock = block.number + _duration; // 40 blocks = 10 min
        owner = msg.sender;
        fee = _fee;
        nonce = 0; 
        amount = 0;
    }
  
    // ---------- Modifiers ----------
    
    bool locked;
    modifier noReentrancy() {
        require(!locked, "Reentrant call.");
        locked = true;
        _;
        locked = false;
    }
        
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this.");
        _;
    }
    
    modifier notOwner() {
        require(msg.sender != owner, "Owner can't participate.");
        _;
    }
    
    modifier onlyBeforeEnd() {
        require(block.number <= endBlock, "Registration already ended.");
        _;
    }
    
    modifier onlyAfterEnd() {
        require(block.number > endBlock, "Registration is still active.");
        _;
    }
    
    modifier participationLimit() {
        require(agents.length > registrations, "Participant limit reached.");
        _;
    }
    
    receive() external payable {
        require(msg.value >= fee, "You must pay the fee.");
        require(!paid[msg.sender], "You can't register twice.");
        amount += msg.value; 
        paid[msg.sender] = true;
    }
    
    // ---------- Agent functions ----------
    
    /// @return get agent' information
    function getAgentInfo(uint _index) onlyOwner public view returns(uint, address, uint[] memory) {
        require(_index < agents.length && _index >= 0, "Invalid index.");
        return (agents[_index].idAgent, agents[_index].direction, agents[_index].preferences);
    }
    
    /// @notice Register a new participant
    /// @param _preferences agent' preferences
    function regAgent(uint[] memory _preferences) notOwner onlyBeforeEnd public {
        require(paid[msg.sender], "Please, pay the fee before registration.");
        require(!registered[msg.sender], "Agent is already registered.");
        Agent memory newAgent = Agent(agents.length, msg.sender, _preferences);
        agents.push(newAgent);
        registered[msg.sender] = true;
    }
    
    /// @notice allows withdrawal of money deposited by participants
    function withdraw() public onlyOwner onlyAfterEnd noReentrancy {
        (bool success, ) = owner.call{value:amount}('');
        require(success, "Transfer failed.");
    }
    
    // ---------- Individual functions ----------
    
    /// @notice create a new individual
    /// @param _popSize population' size
    function createIndiv(uint _popSize) onlyOwner onlyAfterEnd public {
        for(uint i = 0; i < _popSize; i++){ 
            uint[] memory genes = new uint[](geneLength);
            for(uint r = 0; r < geneLength; r++){
                genes[r] = random(agents.length);
            }
            Individual memory newIndiv = Individual(0, genes);
            population.push(newIndiv);
        }
    }
    
    // ---------- Algorithm functions ----------
    
    /// @notice Calculate the fitness of the population
    function calculateFitness() onlyOwner onlyAfterEnd public {
        for(uint j = 0; j < population.length; j++){
            uint[] memory assignments = new uint[](agents.length);
            for(uint i = 0; i < geneLength; i++){
                assignments[population[j].genes[i]] += agents[population[j].genes[i]].preferences[i];
            }
            population[j].fitness = getMin(assignments);
        } 
    }
    
    /// @notice Returns the minimum utility among all agents
    /// @param _assignments accumulation of utilities
    /// @return the minimum utility
    function getMin(uint[] memory _assignments) internal pure returns(uint) {
        uint min = _assignments[0];
        for(uint r = 0; r < _assignments.length; r++){
            if(_assignments[r] < min)
                min = _assignments[r];
        }
        return min;
    }
    
    /// @notice Performs the crossover of the individuals of the population
    function crossover() onlyOwner onlyAfterEnd public {
        for(uint k = elitism; k < population.length; k++){
            for(uint i = 0; i < geneLength; i++){
                if(random(10) <= crossoverRate)
                    population[k].genes[i] = population[random(population.length)].genes[i];
                else
                    population[k].genes[i] = population[random(population.length)].genes[i];
            }
        }
    }
    
    /// @notice Performs the mutation of the individuals of the population
    function mutate() onlyOwner onlyAfterEnd public {
        for(uint k = elitism; k < population.length; k++){
            for(uint i = 0; i < geneLength; i++){
                if(random(10) <= mutationRate){
                    population[k].genes[i] = random(agents.length);
                }
            }
        }
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
    
    // ---------- Support functions ----------
    
    /// @notice gets the best individual of the population
    /// @return The fittest 
    function getBest() onlyAfterEnd public view returns (uint, uint[] memory) {
        Individual memory best = population[0];
        for(uint i = 1; i < population.length; i++){
            if(best.fitness < population[i].fitness)
                best = population[i];
        }
        return (best.fitness, best.genes);
    }
}
