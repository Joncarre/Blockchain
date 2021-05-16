# Egalitarian social welfare into Ethereum blockchain

We present the code of a smart contract that allows auctions where the objective is egalitarian social welfare, i.e., maximizing the utility of the agent (participant) that receives the least utility once the auction has ended. La idea de este contrato es la siguiente: una entidad (dueña del contrato) despliega el contrato en la blockchain de Ethereum y abre un periodo de registro. Durante ese tiempo, los agentes pueden registrarse en la subasta habiendo pagado una tasa de registro. Cuando el tiempo de registro ha finalizado, la entidad procede a ejecutar un algoritmo genético, el cual trata de encontrar la mejor solución a nuestro problema. En la siguiente figura podemos observar los pasos que se siguen:

Figura 1

Ejemplo de ejecución

Las pruebas son realizadas con Remix, el IDE de Ethereum. Remix permite ejecutar pruebas de manera local y conectarse a redes externas, como por ejemplo la red de pruebas Ropsten. Además, nos provee de diez address con 100 ethers cada una de ellas. A continuación mostramos un ejemplo de la ejecución del smart contract y cómo funciona el contrato una vez desplegado. 

En primer lugar, comenzamos observando las address. Tomemos la primera de ellas como la address de la entidad que despliega el contrato.

ima0

A la hora de desplegar el contrato, la entidad puede establecer ciertos parámetros como por ejemplo la tasa de registro, la duración del periodo de participación, si el algoritmo es elitista, etc. At this point, we introduce a good practice for timing the participation period, which is to use the block.number. We know with a fair amount of certainty that Ethereum blocks are generated roughly every 15 seconds; consequently, we can infer timestamps from these numbers rather than the spoofable timestamp fields. If we build our SC correctly, this abstraction should be invisible to the user, which allows us to use a startBlock and endBlock.

ima1

Una vez que el contrato es desplegado, se habilitan las distintas funciones. Además de estas, el contrato posee funciones de tipo internal, es decir: funciones que no son accesibles por direcciones externas (EOAs). Así pues, los agentes proceden a (a) pagar la tasa de participación y (b) registrarse en la subasta. 

ima2

Cuando los agentes se han registrado, el owner del contrato puede consultar la información de cada uno de ellos. Concretamente: id del agente, dirección y preferencias por los recursos disponibles.

ima4

Durante esta fase y las siguientes, existen ciertas restricciones en cuanto a la ejecución de funciones. Estas restricciones nos ayudan a tener una mayor organización sobre los privilegios de los roles que intervienen en la subasta, así como asegurarnos que los agentes malintencionados no puedan hacer un mal uso del contrato. Por ejemplo: si un agente intenta registrarse en la subasta antes de pagar la tasa de registro, la transacción será rechazada y se obtendrá el siguiente error:

transact to Algorithm.regAgent errored: VM error: revert. revert The transaction has been reverted to the initial state. Reason provided by the contract: "Please, pay the fee before registration.

Todas las restricciones pueden ser consultadas en el código mirando las etiquetas modifier y require. Siguiendo con la ejecución, en nuestro ejemplo hemos registrados 3 agentes en la subasta y cada uno ha pagado una tasa de 2 Ether (2000000000 gwei). Cuando volvemos a cambiar a la dirección del owner y consultamos el dinero almacenado en el contrato, efectivamente observamos que hay 6 Ethers.

ima3

Una vez que el periodo de registro ha finalizado, el owner puede ejecutar la función withdraw y lanzar el algoritmo. El algoritmo consta de diferentes funciones que se corresponden con las fases típicas que encontramos en los algoritmos genéticos. Al finalizar las correspondientes transacciones, tanto los agentes como el owner pueden consultar el resultado del reparto. La siguiente imagen muestra el mejor reparto encontrado por el algoritmo, donde cada número del vector se corresponde con el idAgent de cada uno de los agentes. Además de eso, también se muestra el fitness alcanzado.

ima6

Si miramos el Ether disponible en cada dirección, observamos cómo el owner (primera dirección) posee unos 6 Ethers más que al principio. Además, se ha descantado aproximadamente 2 Ether a los agentes que se han inscrito en la subasta. El Ether extra que ha sido descontado se debe a que los agentes también deben pagar el propio coste de ejecutar la transacción que permite registrarse en la subasta, siendo este un coste prácticamente irrelevante. Para ser exactos, una de estras transacciones cuesta menos de 1 dólar. Además, lo que se espera es que en la tasa de participación ya esté incluido este coste, pues la entidad sabe de antemano el coste de ejecución. 
