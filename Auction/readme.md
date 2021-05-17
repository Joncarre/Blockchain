**Egalitarian social welfare into Ethereum blockchain**
==============
----------

We present the code of a smart contract that allows auctions where the objective is egalitarian social welfare, i.e., maximizing the utility of the agent (participant) that receives the least utility once the auction has ended. The idea of this contract is as follows: an entity (owner of the contract) deploys the contract on the Ethereum blockchain and opens a registration period. During that time, agents can register for the auction having paid a registration fee. When the registration time is over, the entity proceeds to run a genetic algorithm, which tries to find the best solution to our problem. In the following figure we can observe the steps that are followed:

![enter image description here](https://github.com/Joncarre/Solidity-language/blob/main/Auction/images/ima7.PNG)

# Example of execution

The tests are performed with Remix, the Ethereum IDE. [Remix](https://remix.ethereum.org/) allows us to run tests locally and connect to external networks, such as the Ropsten testnet. In addition, it provides us with ten addresses with 100 Ethers each. Below we show an example of the execution of the smart contract and how the contract works once deployed.

First, we start by looking at the addresses. Let's take the first one as the address of the entity deploying the contract.

![enter image description here](https://github.com/Joncarre/Solidity-language/blob/main/Auction/images/ima0.png)

When deploying the contract, the entity can set certain parameters such as the registration fee, the duration of the participation period, whether the algorithm is elitist, etc. At this point, we introduce a good practice for timing the participation period, which is to use the `block.number`. We know with a fair amount of certainty that Ethereum blocks are generated roughly every 15 seconds; consequently, we can infer timestamps from these numbers rather than the spoofable timestamp fields. If we build our SC correctly, this abstraction should be invisible to the user, which allows us to use a `startBlock` and `endBlock`.

![enter image description here](https://github.com/Joncarre/Solidity-language/blob/main/Auction/images/ima1.PNG)

Once the contract is deployed, the various functions are enabled. In addition to these, the contract has internal type functions, i.e. functions that are not accessible by external addresses (EOAs). Thus, agents proceed to *(a)* pay the participation fee and *(b)* register for the auction.

![enter image description here](https://github.com/Joncarre/Solidity-language/blob/main/Auction/images/ima2.PNG)

Once the agents have registered, the contract owner can consult the information of each agent. Specifically: agent id, address and preferences for available resources.

![enter image description here](https://github.com/Joncarre/Solidity-language/blob/main/Auction/images/ima4.PNG)

During this and the following phases, there are certain restrictions on the execution of functions. These restrictions help us to have a better organization over the privileges of the roles involved in the auction, as well as to make sure that malicious agents cannot misuse the contract. For example: if an agent tries to register in the auction before paying the registration fee, the transaction will be rejected and you will get the following error:

`transact to Algorithm.regAgent errored: VM error: revert. revert The transaction has been reverted to the initial state. Reason provided by the contract: "Please, pay the fee before registration".`

All the restrictions can be consulted in the code by looking at the `modifier` and `require` tags. Continuing with the execution, in our example we have registered 3 agents in the auction and each one has paid a fee of 2 Ether (2000000000 gwei). When we switch back to the owner's address and look at the money stored in the contract, we indeed see that there are 6 Ethers.

![enter image description here](https://github.com/Joncarre/Solidity-language/blob/main/Auction/images/ima3.PNG)

Once the registration period is over, the owner can execute the withdraw function and launch the algorithm. The algorithm consists of different functions that correspond to the typical phases found in genetic algorithms. At the end of the corresponding transactions, both the agents and the owner can consult the result of the deal. The following image shows the best allocation found by the algorithm, where each number of the vector corresponds to the `idAgent` of each of the agents. In addition to that, the fitness achieved is also shown. Therefore, when each of the agents accesses it, they are all accessing exactly the same information, which ensures the veracity of the results.

![enter image description here](https://github.com/Joncarre/Solidity-language/blob/main/Auction/images/ima6.PNG)

If we look at the Ether available in each direction, we observe how the owner (first address) has about 6 Ethers more than at the beginning. In addition, about 2 Ether has been discounted to the agents who have registered for the auction. The extra Ether that has been discounted is due to the fact that the agents must also pay the cost of executing the transaction that allows them to register in the auction, being this a practically irrelevant cost. To be exact, one of these transactions costs less than $1. Moreover, it is expected that this cost is already included in the participation fee, since the entity knows in advance the cost of execution.
