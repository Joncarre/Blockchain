pragma solidity ^0.4.0;

contract Agent {
    uint idAgent;
    address direction;
    uint[] O_preferences;
    
    /// @notice Contructor del contraro 'Agent'
    constructor(uint _idAgent, address _direction, uint[] _O_preferences) public {
        idAgent = _idAgent;
        direction = _direction;
        O_preferences = _O_preferences;
    }
    
    /// @notice Retorna la información de un agente
    /// @return retorna los datos del agente
    function getAgentInfo() external view returns(uint, address, uint[]) {
        return (idAgent, direction, O_preferences);
    }
}