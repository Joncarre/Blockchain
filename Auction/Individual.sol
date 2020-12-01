pragma solidity ^0.4.0;

contract Individual {
    uint geneLength;
    uint fitness;
    uint[] genes;
    uint nonce;

    /// @notice Contructor del contraro 'Individual'
    constructor() public{
        geneLength = 10;
        fitness = 0;
        genes = new uint[](geneLength);
        nonce = 0;
    }
    
    /// @notice getGen
    /// @param _index índice del gen
    /// @return el gen en sí
    function getGene(uint _index) external view returns (uint) {
        return genes[_index];
    }
    
    /// @notice getGenes
    /// @return el vector de genes
    function getGenes() external view returns (uint[]) {
        return genes;
    }
    
    /// @notice setGen
    /// @param _index del gen
    /// @param _gen gen a insertar
    function setGene(uint _index, uint _gen) public {
        genes[_index] = _gen;
    }
    
    /// @notice getFitness
    /// @return el valor fitness del individuo
    function getFitness() public view returns (uint) {
        return fitness; 
    }
    
    /// @notice setFitness
    /// @param _fitness nuevo fitness
    function setFitness(uint _fitness) public {
        fitness = _fitness;
    }
    
    /// @notice getGenesLenght
    /// @return la longitud que tiene un individuo
    function getGenesLenght() public view returns (uint) {
        return geneLength; 
    }
    
    /// @notice Lleva a cabo la creación de los genes del individuo
    function createIndividual(uint _indiv, uint _numAgents) public {
        for(uint i = 0; i < geneLength; i++){
            genes[i] = random(_indiv, _numAgents);
        }
    }
    
    /// @notice Genera un número aleatorio dentro de un intervalo
    /// @param _interval índice superior del intervalo (abierto) del valor random
    /// @dev now, msg.sender y nonce son el timestamp del bloque, quién hizo la llamada y un número incremental respectivamente
    /// @return El número generado
    function random(uint _indiv, uint _interval) internal returns (uint) {
        uint randNumber = uint(keccak256(abi.encodePacked(now, msg.sender, _indiv + nonce))) % _interval;
        nonce++;
        return randNumber;
    }
}