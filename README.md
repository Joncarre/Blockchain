# Solidity Language Examples Repository

Welcome to this repository showcasing various projects and examples implemented using the Solidity programming language for the Ethereum blockchain.

## Featured Project: Egalitarian Social Welfare Auction

One of the key projects in this repository is the `Auction` smart contract.

### Overview

This smart contract facilitates an auction mechanism designed to achieve **egalitarian social welfare**. The primary goal is to maximize the utility (satisfaction) of the participant who receives the *least* utility from the final allocation of resources.

### How it Works

1.  **Deployment & Setup:** An entity (the contract `owner`) deploys the contract, setting parameters like registration fees and duration.
2.  **Registration Phase:** Participants (`agents`) pay a fee and register their preferences for the available resources within a defined time window (managed by `block.number`).
3.  **Genetic Algorithm Execution:** Once the registration period ends, the `owner` triggers an on-chain genetic algorithm. This algorithm iteratively evolves a population of potential resource allocations (individuals) through processes like crossover and mutation to find an optimal solution based on the egalitarian welfare objective.
4.  **Results:** After the algorithm completes, both the owner and participants can view the final resource allocation and the achieved minimum utility (fitness), ensuring transparency.

### Key Solidity Concepts Demonstrated

The `Auction.sol` contract demonstrates several core Solidity concepts:

*   **Structs:** Defining complex data types (`Agent`, `Individual`).
*   **Mappings:** Associating addresses with status (`paid`, `registered`).
*   **State Variables:** Storing contract data like `owner`, `endBlock`, `fee`, `agents`, `population`.
*   **Functions & Visibility:** Public, internal, and view functions (`regAgent`, `calculateFitness`, `getMin`, `getBest`).
*   **Modifiers:** Implementing access control and state checks (`onlyOwner`, `notOwner`, `onlyBeforeEnd`, `onlyAfterEnd`, `noReentrancy`).
*   **Constructor:** Initializing the contract state upon deployment.
*   **Error Handling:** Using `require` statements for validating conditions.
*   **Ether Handling:** Managing registration fees (`receive()` function, `payable` addresses, `call`).

Feel free to explore the `Auction` directory and other projects within this repository to learn more about Solidity development.

---
*Created by Jonathan Carrero*
