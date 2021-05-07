pragma solidity ^0.5.2;

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
    mapping(address => bool) registered;
    
    // Auction
    address payable owner;
    uint endBlock;
    uint fee;
    uint registrations = 10;
    
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
    }
    
    // ---------- Modifiers ----------
        
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
    
    // ---------- Agent functions ----------
    
    /// @return get agent' information
    function getAgentInfo(uint _index) onlyOwner public view returns(uint, address, uint[] memory) {
        require(_index < agents.length && _index >= 0, "Invalid index.");
        return (agents[_index].idAgent, agents[_index].direction, agents[_index].preferences);
    }
    
    /// @notice Register a new participant
    /// @param _preferences agent' preferences
    function regAgent(uint[] memory _preferences) notOwner onlyBeforeEnd public {
        require(msg.sender.balance - fee >= 0, "You can't pay the fee.");
        require(!registered[msg.sender], "Agent is already registered.");
        Agent memory newAgent = Agent(agents.length, msg.sender, _preferences);
        agents.push(newAgent);
        registered[msg.sender] = true;
        // the agent must pay the fee to participate.
        // owner must recieve that fee
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
    
    /// @notice Calcular el fitness de la población
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
    
    /// @notice Realiza el cruzamiento de los individuos de la población
    function crossover() onlyOwner onlyAfterEnd public {
        for(uint k = elitism; k < population.length; k++){
            for(uint i = 0; i < geneLength; i++){
                if(random(crossoverRate) < 10)
                    population[k].genes[i] = population[random(population.length)].genes[i];
                else
                    population[k].genes[i] = population[random(population.length)].genes[i];
            }
        }
    }
    
    /// @notice Realiza la mutación de los individuos de la población
    function mutate() onlyOwner onlyAfterEnd public {
        for(uint k = elitism; k < population.length; k++){
            for(uint i = 0; i < geneLength; i++){
                if(random(mutationRate) < 10){
                    population[k].genes[i] = random(agents.length);
                }
            }
        }
    }
    
    /// @notice Genera un número aleatorio dentro de un intervalo
    /// @param _interval índice superior del intervalo (abierto) del valor random
    /// @dev now, msg.sender y nonce son el timestamp del bloque, quién hizo la llamada y un número incremental respectivamente
    /// @return El número generado
    function random(uint _interval) internal returns (uint) {
        uint randNumber = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % _interval;
        nonce++;
        return randNumber;
    }
    
    // ---------- Support functions ----------
    
    /// @notice Selecciona al mejor individuo de la población
    /// @return El individuo
    function getBest() onlyAfterEnd public view returns (uint, uint[] memory) {
        Individual memory best = population[0];
        for(uint i = 1; i < population.length; i++){
            if(best.fitness < population[i].fitness)
                best = population[i];
        }
        return (best.fitness, best.genes);
    }
}
