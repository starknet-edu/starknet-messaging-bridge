# Puente de mensajería StarkNet

¡Bienvenidos! Este es un taller automatizado que explicará cómo usar el puente de mensajería StarkNet L1 <-> L2 para crear poderosas aplicaciones de capas cruzadas.

Está dirigido a desarrolladores que:

- Comprenden la sintaxis de El Cairo
- Comprenden la sintaxis de Solidity
- Comprenden el estándar de token ERC20
- Comprenden el esándar ERC721

## Introducción

### Descargo de responsabilidad

​No espere ningún tipo de beneficio al usar esto, aparte de aprender un montón de cosas interesantes sobre StarkNet, el primer paquete acumulativo de validez de propósito general en Ethereum Mainnnet.
​
StarkNet todavía está en Alfa. Esto significa que el desarrollo está en curso y que la pintura no está seca en todas partes. Las cosas mejorarán, y mientras tanto, ¡hacemos que las cosas funcionen con un poco de cinta adhesiva aquí y allá!
​

### Cómo funciona

El objetivo de este tutorial es que cree e implemente contratos en StarkNet y Ethereum que interactuarán entre sí. En otras palabras, creará su propio puente L1 <-> L2.

Su progreso será verificado por un [contrato de evaluador](contratos/Evaluador.cairo), implementado en StarkNet, que le otorgará puntos en forma de [tokens ERC20](contratos/token/ERC20/TDERC20.cairo).

Cada ejercicio requerirá que agregue funcionalidad a su puente.

- La primera parte le permite enviar y recibir mensajes de L1 a L2, sin tener que codificar necesariamente.
- La segunda parte requiere que codifiques contratos inteligentes en L1 y L2 que puedan enviar mensajes a las contrapartes de L2 y L1.
- La segunda parte requiere que codifique contratos inteligentes en L1 y L2 que puedan recibir mensajes de contrapartes L2 y L1.

Para cada ejercicio, deberá escribir una nueva versión en su contrato, implementarlo y enviarlo al evaluador para su corrección.
​
​
### ¿Dónde estoy?

Este taller es el cuarto de una serie destinada a enseñar cómo construir en StarkNet. Echa un vistazo a lo siguiente:

| Tema                                           | GitHub repo                                                                            |
| ---------------------------------------------- | -------------------------------------------------------------------------------------- |
| Aprenda a leer el código de El Cairo           | [Cairo 101](https://github.com/starknet-edu/starknet-cairo-101)                        |
| Implemente y personalice un ERC721 NFT         | [StarkNet ERC721](https://github.com/starknet-edu/starknet-erc721)                     |
| Implemente y personalice un token ERC20        | [StarkNet ERC20](https://github.com/starknet-edu/starknet-erc20)                       |
| Cree una app de capa cruzada (usted está aquí) | [StarkNet messaging bridge](https://github.com/starknet-edu/starknet-messaging-bridge) |
| Depure sus contratos de El Cairo fácilmente    | [StarkNet debug](https://github.com/starknet-edu/starknet-debug)                       |
| Diseña tu propio contrato de cuenta            | [StarkNet account abstraction](https://github.com/starknet-edu/starknet-accounts)      |


### Proporcionar comentarios y obtener ayuda

Una vez que haya terminado de trabajar en este tutorial, ¡sus comentarios serán muy apreciados!

**Complete [este formulario](https://forms.reform.app/starkware/untitled-form-4/kaes2e) para informarnos qué podemos hacer para mejorarlo.**

​
Y si tiene dificultades para seguir adelante, ¡háganoslo saber! Este taller está destinado a ser lo más accesible posible; queremos saber si no es el caso.

​
¿Tienes una pregunta? Únase a nuestro [servidor Discord](https://starknet.io/discord), regístrese y únase al canal #tutorials-support
​

### Contribuyendo

Este proyecto se puede mejorar y evolucionará a medida que StarkNet madure. ¡Sus contribuciones son bienvenidas! Aquí hay cosas que puede hacer para ayudar:

- Crea una sucursal con una traducción a tu idioma
- Corrija los errores si encuentra alguno.
- Agregue una explicación en los comentarios del ejercicio si cree que necesita más explicación

​
## Preparándose para trabajar

### Paso 1: clonar el repositorio

*  Oficial

```bash
clon de git https://github.com/starknet-edu/starknet-messaging-bridge
cd starknet-messaging-bridge
```

* Nadai con Soluciones

```bash
gh repo clone Nadai2010/Nadai-Starknet-Edu-Bridge-L2-L1
cd Nadai-Starknet-Edu-Bridge-L2-L1
```

### Paso 2: configure su entorno

Hay dos formas de configurar su entorno en StarkNet: una instalación local o usando un contenedor docker

- Para usuarios de Mac y Linux, recomendamos
- Para usuarios de Windows recomendamos docker

Para obtener instrucciones de configuración de producción, escribimos [este artículo](https://medium.com/starknet-edu/the-ultimate-starknet-dev-environment-716724aef4a7).

#### Opción A: configurar un entorno Python local

- Configure el entorno siguiendo [estas instrucciones](https://starknet.io/docs/quickstart.html#quickstart)
- Instale [los contratos cairo de OpenZeppelin](https://github.com/OpenZeppelin/cairo-contracts).

```bash
pip install openzeppelin-cairo-contratos
```

Si la error pruebe

```bash
gh repo clone OpenZeppelin/cairo-contracts
```

#### Opción B: usar un entorno dockerizado

-Linux y macos

Pra mac m1:

```bash
alias cairo='docker run --rm -v "$PWD":"$PWD" -w "$PWD" shardlabs/cairo-cli:latest-arm'
```

Para procesadores amd

```bash
alias cairo='docker run --rm -v "$PWD":"$PWD" -w "$PWD" shardlabs/cairo-cli:latest'
```

- Windows

```bash
docker run --rm -it -v ${pwd}:/work --workdir /work shardlabs/cairo-cli:latest
```

### Paso 3: pruebe que puede compilar el proyecto

```bash
starknet-compile contracts/Evaluator.cairo
```
​

## Trabajando en el tutorial

### Flujo de trabajo

La comunicación L2 -> L1 tarda ~30 minutos, por lo que se recomienda enviar los mensajes de L2 a L1 lo antes posible y hacer los ejercicios en L1 mientras tanto.

Para hacer este tutorial tendrás que interactuar con el contrato [`Evaluator.cairo`](contracts/Evaluator.cairo). Para validar un ejercicio tendrás que

- Lea el código del evaluador para averiguar qué se espera de su contrato
- Personaliza el código de tu contrato
- Implementarlo en la red de prueba de StarkNet. Esto se hace usando la CLI.
- Registre su ejercicio para corrección, usando la función `submit_exercise` en el evaluador. Esto se hace usando Voyager.
- Llame a la función correspondiente en el contrato del evaluador para corregir su ejercicio y recibir sus puntos. Esto se hace usando Voyager.
- También hay un [contrato de evaluador](contracts/L1/Evaluator.sol) en L1, que comprobará la solidez de tu trabajo. El flujo de trabajo para usarlo es el mismo que el anterior, solo en L1.

### Ejercicios y direcciones de contratos

| Contract code                                                                                                                    | Contract on voyager                                                                                                                                                           |
| -------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [L2 Evaluator](contracts/Evaluator.cairo)                                                                                        | [0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99](https://goerli.voyager.online/contract/0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99) |
| [Points counter ERC20](contracts/token/ERC20/TDERC20.cairo)                                                                      | [0x38ec18163a6923a96870f3d2b948a140df89d30120afdf90270b02c609f8a88](https://goerli.voyager.online/contract/0x38ec18163a6923a96870f3d2b948a140df89d30120afdf90270b02c609f8a88) |
| [L2 Dummy NFT](contracts/l2nft.cairo)                                                                                            | [0x6cc3df14b8b3e8c05ad19c74f373e110bba0380b2799bcd9f717d31d2757625](https://goerli.voyager.online/contract/0x6cc3df14b8b3e8c05ad19c74f373e110bba0380b2799bcd9f717d31d2757625) |
| [L1 Evaluator](contracts/L1/Evaluator.sol)                                                                                       | [0x8055d587A447AE186d1589F7AAaF90CaCCc30179](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179)                                                  |
| [L1 Dummy token](contracts/L1/DummyToken.sol)                                                                                    | [0x0232CB90523F181Ab4990Eb078Cf890F065eC395](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395)                                                  |
| [L1 Messaging NFT](contracts/L1/MessagingNft.sol)                                                                                | [0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E)                                                  |
| [StarkNet Core Contract Proxy](https://goerli.etherscan.io/address/0xde29d060d45901fb19ed6c6e959eb22d8626708e#readContract)      | [0xde29d060D45901Fb19ED6C6e959EB22d8626708e](https://goerli.etherscan.io/address/0xde29d060d45901fb19ed6c6e959eb22d8626708e)                                                  |
| [Goerli Faucet (0.1 ETH / 2 hours)](https://goerli.etherscan.io/address/0x25864095d3eB9F7194C1ccbb01871c9b1bd5787a#readContract) | [0x25864095d3eB9F7194C1ccbb01871c9b1bd5787a](https://goerli.etherscan.io/address/0x25864095d3eB9F7194C1ccbb01871c9b1bd5787a#writeContract)     


## Lista de tareas

### Ejercicio 0 - Enviar un mensaje L2→L1→L2 con contratos existentes (2 pts)

Use un contrato implementado previamente para acuñar tokens ERC20 en L1 desde L2. Se pasa un mensaje secreto con los mensajes; asegúrese de encontrarlo para acumular sus puntos.

- Call function [`ex_0_a`](contracts/Evaluator.cairo#L121) of [*L2 Evaluator*](https://goerli.voyager.online/contract/0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99)
- Debe especificar una dirección L1 y una cantidad de ERC20 para acuñar
- El mensaje secreto se envía de L2 a L1 en esta etapa.
- Llame a [`mint`](contracts/L1/DummyToken.sol#L37) de [*L1 DummyToken*](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395)
  - Debe demostrar que conoce el valor secreto en este paso
- Llame a [`i_have_tokens`](contracts/L1/DummyToken.sol#L48) de [*L1 DummyToken*](https://goerli.etherscan.io/address/0x0232CB90523F181Ab4990Eb078Cf890F065eC395)
  - Esta función verifica que hayas podido acuñar tokens ERC20 y luego enviará un mensaje a L2 para acreditar tus puntos
  - Esto se hace usando [`ex_0_b`](contracts/Evaluator.cairo#L143) del evaluador L2

---

* Nadai con Soluciones [Ejercicio 0](https://github.com/Nadai2010/Nadai-Starknet-Edu-Bridge-L2-L1/blob/master/contracts/Soluci%C3%B3n/ex0.md)

---

### Ejercicio 1 - Envía un mensaje L2→L1 con tu contrato (2 pts)

Escriba e implemente un contrato en L2 que *envíe* mensajes a L1.

- Escriba un contrato en L2 que enviará un mensaje a [L1 MessagingNft](https://goerli.etherscan.io/address/0x6DD77805FD35c91EF6b2624Ba538Ed920b8d0b4E) y activará [`createNftFromL2`](contracts/L1/MessagingNft.sol#L35)
- Su función debe llamarse [`create_l1_nft_message`](contracts/Evaluator.cairo#L198)
- Despliega tu contrato
- Envíe la dirección del contrato a L2 Evaluator llamando a su [`submit_exercise`](contracts/Evaluator.cairo#L166)
- Llame a [`ex1a`](contracts/Evaluator.cairo#L188) de L2 Evaluator para activar el envío del mensaje a L2
- Llame a [`createNftFromL2`](contracts/L1/MessagingNft.sol#L35) de L1 MessagingNft para activar el consumo de mensajes en L1
  - L1 MessagingNft [devuelve](contracts/L1/MessagingNft.sol#L47) un mensaje a L2 para [acreditar sus puntos](contracts/Evaluator.cairo#L205) en L2

---

* Nadai con Soluciones [Ejercicio 1](https://github.com/Nadai2010/Nadai-Starknet-Edu-Bridge-L2-L1/blob/master/contracts/Soluci%C3%B3n/ex01.md)

---

### Ejercicio 2 - Envía un mensaje L1→L2 con tu contrato (2 pts)

Escriba e implemente un contrato en L1 que *envíe* mensajes a L2.

- Escriba un contrato en L1 que enviará un mensaje a L2 Evaluator y activará [`ex2`](contracts/Evaluator.cairo#L221)
  - Puede comprobar cómo L1 MessagingNft [envía](contratos/L1/MessagingNft.sol#L47) un mensaje a L2 para obtener algunas ideas.
  - Puede obtener la dirección más reciente del StarkNet Core Contract Proxy en Goerli ejecutando `starknet get_contract_addresses --network alpha-goerli` en su CLI
  - Aprenda cómo obtener el [selector](https://starknet.io/docs/hello_starknet/l1l2.html#receive-a-message-from-l1) de una función de contrato de StarkNet
- Despliega tu contrato
- Activar el envío de mensajes en L1. Sus puntos se atribuyen automáticamente en L2.

---

* Nadai con Soluciones [Ejercicio 2](https://github.com/Nadai2010/Nadai-Starknet-Edu-Bridge-L2-L1/blob/master/contracts/Soluci%C3%B3n/ex02.md)

---

### Ejercicio 3 - Recibe un mensaje L2→L1 con tu contrato (2 pts)

- Escriba un contrato en L1 que recibirá un mensaje de la función [`ex3_a`](contracts/Evaluator.cairo#L231).
  - Asegúrese de que su contrato pueda manejar el mensaje.
  - Su función de consumo de mensajes debe llamarse [`consumeMessage`](contracts/L1/Evaluator.sol#L51)
- Implemente su contrato L1
- Llame a [`ex3_a`](contracts/Evaluator.cairo#L231) de [*L2 Evaluator*](https://goerli.voyager.online/contract/0x595bfeb84a5f95de3471fc66929710e92c12cce2b652cd91a6fef4c5c09cd99) para enviar un mensaje L2→L1
- Llame a [`ex3`](contracts/L1/Evaluator.sol#L32) de *L1 Evaluator*, que activa el consumo de mensajes de su contrato L1
  - El evaluador de L1 también [devolverá](contracts/L1/Evaluator.sol#L57) un mensaje a L2 para distribuir sus puntos

---

* Nadai con Soluciones [Ejercicio 3](https://github.com/Nadai2010/Nadai-Starknet-Edu-Bridge-L2-L1/blob/master/contracts/Soluci%C3%B3n/ex03.md)

---


### Ejercicio 4 - Recibe un mensaje L1→L2 con tu contrato (2 pts)

- Escribir un contrato L2 que pueda recibir un mensaje de [`ex4`](contracts/L1/Evaluator.sol#L60) de [*L1 Evaluator*](https://goerli.etherscan.io/address/0x8055d587A447AE186d1589F7AAaF90CaCCc30179 )
  - Puede nombrar su función como desee, ya que proporciona el selector de función como parámetro en L1
- Implemente su contrato en L2
- Llame a [`ex4`](contracts/L1/Evaluator.sol#L60) de *L1 Evaluator* para enviar el valor aleatorio a su contrato L2
- Envíe la dirección de su contrato L2 llamando a [`submit_exercise`](contracts/Evaluator.cairo#L166) de *L2 Evaluator*
- Llame a [`ex4_b`](contracts/Evaluator.cairo#L266) de *L2 Evaluator* que verificará que completó su trabajo correctamente y distribuirá sus puntos

---

* Nadai con Soluciones [Ejercicio 4](https://github.com/Nadai2010/Nadai-Starknet-Edu-Bridge-L2-L1/blob/master/contracts/Soluci%C3%B3n/ex04.md)

---

## Anexo - Herramientas y recursos útiles

### Conversión de datos a y desde decimal

Para convertir datos en fieltro, use el script [`utils.py`](utils.py)
Para abrir Python en modo interactivo después de ejecutar el script

  ```bash
  python -i utils.py
  ```

  ```python
  >>> str_to_felt('ERC20-101')
  1278752977803006783537
  ```


### Comprobando tu progreso y contando tus puntos

​Sus puntos se acreditarán en su billetera; aunque esto puede tomar algún tiempo. Si desea controlar su conteo de puntos en tiempo real, ¡también puede ver su saldo en Voyager!
​

- Vaya al [contador ERC20](https://goerli.voyager.online/contract/0x38ec18163a6923a96870f3d2b948a140df89d30120afdf90270b02c609f8a88#readContract) en voyager, en la pestaña "leer contrato"
- Ingrese su dirección en decimal en la función "balanceOf"

También puede verificar su progreso general [aquí] (https://starknet-tutorials.vercel.app)
​


### Estado de la transacción

​¿Envió una transacción y se muestra como "no detectada" en voyager? Esto puede significar dos cosas:
​
- Su transacción está pendiente y se incluirá en un bloque en breve. Entonces será visible en Voyager.
- Su transacción no fue válida y NO se incluirá en un bloque (no existe una transacción fallida en StarkNet).
​
Puede (y debe) verificar el estado de su transacción con la siguiente URL [https://alpha4.starknet.io/feeder_gateway/get_transaction_receipt?transactionHash=](https://alpha4.starknet.io/feeder_gateway/get_transaction_receipt?transactionHash=), donde puede agregar el hash de su transacción.
​

### Artículos y documentación

- [Mecanismo de mensajería | Documentos de StarkNet](https://docs.starknet.io/docs/L1%3C%3EL2%20Communication/messaging-mechanism)
- [Interactuando con contratos L1 | Documentación de StarkNet](https://starknet.io/docs/hello_starknet/l1l2.html)
- Proyecto de muestra: [graffiti de StarkNet | GitHub](https://github.com/l-henri/StarkNet-graffiti)
- [Hilo en StarkNet ⇄ Mensajería Ethereum | Twitter](https://twitter.com/HenriLieutaud/status/1466324729829154822)

