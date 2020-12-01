pragma solidity ^0.4.0;

import "Individual.sol";
import "Agent.sol";

/// @title Egalitarian social welfare in Smart contracts
/// @author J. Carrero
contract Auction {
    Agent[] agents;
    Individual[] population;
    uint[] result;
    uint elitism;
    uint crossoverRate;
    uint mutationRate;
    uint nonce;

    /// @notice Contructor del contraro 'Population'
    /// @param _numAgents número de agentes que intervienen en el repart
    /// @param _numResources indica el número de recursos disponibles
    /// @param _elitism indica si la población será elitista (almacenará el fittest)
    constructor(uint _elitism) public {
        elitism = _elitism;
        crossoverRate = 2;
        mutationRate = 4;
        nonce = 0;
    }
    
    /// @notice Evoluciona la población almacenando el Fittest en cada evolución
    /// @param _iterations número de veces que evoluciona la población
    /// @return todos los valores fittest obtenidos
    function evolvePop(uint _iterations) public {
        result = new uint[](_iterations);
        for(uint i = 0; i < _iterations; i++){
            Individual bestIndiv = getBest();
            if(elitism == 1) // is it elitism?
                population[0] = bestIndiv; // Save best indiv
            result[i] = bestIndiv.getFitness(); // Save its fitness in our fittest' vector
            //crossover(); // Crossover phase
            //mutate(); // Mutation phase
            calculateFitness(); // Get fitness phase
        }
    }
    
    /// @notice Create a new individual
    /// @param _popSize population' size
    function createIndiv(uint _popSize) public{
        for(uint i = 0; i < _popSize; i++){  
            Individual newIndiv = new Individual();
            newIndiv.createIndividual(i, agents.length);
            population.push(newIndiv);
        }
    }
    
    /// @notice Registra a un nuevo agente a la subasta
    /// @param _idAgent id del agente
    /// @param _direction direccion de cartera del agente
    /// @param _O_preferences preferencias del agente
    function regAgent(uint _idAgent, address _direction, uint[] _O_preferences) public{
        Agent newAgent = new Agent(_idAgent, _direction, _O_preferences);
        agents.push(newAgent);
    }
    
    /// @notice Calcular el fitness de la población
    function calculateFitness() public{
        for(uint j = 0; j < population.length; j++){
            uint[] memory assignments = new uint[](agents.length);
            for(uint i = 0; i < population[j].getGenesLenght(); i++){
                uint[] memory pref;
                (,,pref) = agents[population[j].getGene(i)].getAgentInfo(); // We get preferences for current agent
                assignments[population[j].getGene(i)] += pref[i];
            }
            population[j].setFitness(getMin(assignments));
        } 
    }
    
    /// @notice Retorna la utilidad mínima entre todos los agentes
    /// @param _assignments acumulación de las utilidades
    /// @return la utilidad mínima
    function getMin(uint[] _assignments) internal pure returns(uint){
        uint min = _assignments[0];
        for(uint r = 0; r < _assignments.length; r++){
            if(_assignments[r] < min)
                min = _assignments[r];
        }
        return min;
    }
    
    /// @notice Realiza el cruzamiento de los individuos de la población
    function crossover() public{
        for(uint k = elitism; k < population.length; k++){
            Individual newIndiv = new Individual();
            for(uint i = 0; i < population[k].getGenesLenght(); i++){
                uint index1 = random(population.length);
                uint index2 = random(population.length);  
                if(random(crossoverRate) < 10)
                    newIndiv.setGene(i, population[index1].getGene(i));
                else
                    newIndiv.setGene(i, population[index2].getGene(i));
            }
            population[k] = newIndiv;
        }
    }
    
    /// @notice Realiza la mutación de los individuos de la población
    function mutate() public{
        for(uint k = elitism; k < population.length; k++){
            for(uint i = 0; i < population[k].getGenesLenght(); i++){
                if(random(mutationRate) < 10){
                    uint gene = random(agents.length);
                    population[k].setGene(i, gene);
                }
            }
        }
    }
    
    /// @notice Selecciona al mejor individuo de la población
    /// @return El individuo
    function getBest() internal returns (Individual) {
        Individual best = new Individual();
        best = population[0];
        for(uint i = 1; i < population.length; i++){
            if(best.getFitness() < population[i].getFitness())
                best = population[i];
        }
        return best;
    }
    
    /// @notice Retorna el tamaño de la población
    /// @return El tamaño
    function getPopSize() public view returns(uint){
        return population.length;
    }
    
    /// @notice Retorna cuantos agentes hay en la subasta
    /// @return El tamaño
    function getAgentSize() public view returns(uint){
        return agents.length;
    }
    
    
    /// @notice Retorna los genes de un individuo de la población
    /// @param _index índice del individuo
    /// @return vector de genes
    function getIndivGenes(uint _index) external view returns (uint[]) {
        return population[_index].getGenes();
    }
    
    /// @notice Genera un número aleatorio dentro de un intervalo
    /// @param _interval índice superior del intervalo (abierto) del valor random
    /// @dev now, msg.sender y nonce son el timestamp del bloque, quién hizo la llamada y un número incremental respectivamente
    /// @return el número generado
    function random(uint _interval) public returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % _interval;
        nonce++;
        return randomnumber;
    }

    /// @notice Obtiene el fitness de un determinado individuo
    /// @param _index índice del individuo
    /// @return el valor fitness
    function getFitnessIndiv(uint _index) public view returns(uint){
        return population[_index].getFitness();
    }
    
    /// @notice Retorna el fittest de cada evolución de la población
    /// @return el vector de resultados
    function getResult() public view returns(uint[]){
        return result;
    }
}