## BNB

## Usage

### Build

shell
$ forge build


### Test

shell
$ forge test


## Coverage Summary:

| Coverage Type    | Rate   | Total | Hit   |
|------------------|--------|-------|-------|
| **Lines**        | 100.0% | 111   | 111   |
| **Functions**    | 100.0% | 29    | 29    |
| **Branches**     | 100.0% | 38    | 38    |

---

### Coverage by File:

| Filename               | Line Coverage | Branch Coverage | Function Coverage |
|------------------------|---------------|------------------|-------------------|
| [RentalUnit.sol](coverage/src/src/RentalUnit.sol.gcov.html)    | 100.0% (104/104) | 100.0% (36/36)  | 100.0% (27/27)   |
| [RentalUnitFactory.sol](coverage/src/src/RentalUnitFactory.sol.gcov.html) | 100.0% (7/7)   | 100.0% (2/2)    | 100.0% (2/2)     |

## GAS Report
| src/RentalUnit.sol:RentalUnit contract |                 |        |        |        |         |
|----------------------------------------|-----------------|--------|--------|--------|---------|
| **Deployment Cost**                    | **Deployment Size** |        |        |        |         |
| 2608244                              | 13091         |        |        |        |         |
| **Function Name**                      | **min**         | **avg** | **median** | **max** | **# calls** |
| addSeason                            | $${\color{green}23805}$$ | $${\color{orange}90726}$$ | 112993 | $${\color{red}112993}$$ | 20      |
| checkAvailability                    | $${\color{green}411}$$   | $${\color{orange}2707}$$  | 1940   | $${\color{red}9182}$$   | 14      |
| endTime                              | $${\color{green}837}$$   | $${\color{orange}1204}$$  | 837    | $${\color{red}2674}$$   | 5       |
| expiryType                           | $${\color{green}272}$$   | 272   | 272    | 272    | 1       |
| getInfo                              | $${\color{green}27209}$$ | $${\color{orange}27542}$$ | 27209  | $${\color{red}29209}$$  | 6       |
| getSeason                            | $${\color{green}1045}$$  | 1045  | 1045   | 1045   | 1       |
| getSetSeasonId                       | $${\color{green}359}$$   | 359   | 359    | 359    | 1       |
| isTokenExpired                       | $${\color{green}774}$$   | $${\color{orange}1229}$$  | 774    | $${\color{red}2597}$$   | 4       |
| name                                 | $${\color{green}3314}$$  | 3314  | 3314   | 3314   | 1       |
| paused                               | $${\color{green}404}$$   | $${\color{orange}1070}$$  | 404    | $${\color{red}2404}$$   | 6       |
| reservationCost                      | $${\color{green}643}$$   | $${\color{orange}2518}$$  | 2643   | $${\color{red}2643}$$   | 16      |
| reserve                              | $${\color{green}21980}$$ | $${\color{orange}119581}$$ | $${\color{red}147483}$$ | 195943 | 19      |
| safeTransferFrom                     | $${\color{green}24742}$$ | 24742 | 24742  | 24742  | 1       |
| setCurrentSeason                     | $${\color{green}23704}$$ | $${\color{orange}50609}$$ | $${\color{red}54244}$$  | 54244  | 15      |
| setPause                             | $${\color{green}23716}$$ | $${\color{orange}35028}$$ | $${\color{red}25938}$$  | 47572  | 9       |
| startTime                            | $${\color{green}793}$$   | $${\color{orange}1160}$$  | 793    | $${\color{red}2630}$$   | 5       |
| supportsInterface                    | $${\color{green}452}$$   | $${\color{orange}532}$$   | 563    | 563    | 6       |
| symbol                               | $${\color{green}3290}$$  | 3290  | 3290   | 3290   | 1       |
| tokenURI                             | $${\color{green}608}$$   | 608   | 608    | 608    | 1       |
| updateCapacity                       | $${\color{green}23703}$$ | $${\color{orange}25657}$$ | 23759  | $${\color{red}29509}$$  | 3       |
| updateCategory                       | $${\color{green}24247}$$ | $${\color{orange}27326}$$ | 27326  | $${\color{red}30405}$$  | 2       |
| updateDescriptions                   | $${\color{green}24347}$$ | $${\color{orange}27426}$$ | 27426  | $${\color{red}30505}$$  | 2       |
| updateImagesUrl                      | $${\color{green}24055}$$ | $${\color{orange}26314}$$ | 24352  | $${\color{red}30536}$$  | 3       |
| updatePricePerNight                  | $${\color{green}23738}$$ | $${\color{orange}25684}$$ | 23754  | $${\color{red}29560}$$  | 3       |
| withdraw                             | $${\color{green}23399}$$ | $${\color{orange}27294}$$ | 27294  | $${\color{red}31189}$$  | 2       |

---

| src/RentalUnitFactory.sol:RentalUnitFactory contract |                 |         |         |         |         |
|------------------------------------------------------|-----------------|---------|---------|---------|---------|
| **Deployment Cost**                                  | **Deployment Size** |         |         |         |         |
| 3101400                                            | 14150         |         |         |         |         |
| **Function Name**                                    | **min**         | **avg** | **median** | **max** | **# calls** |
| computeTokenAddress                                | $${\color{green}41787}$$ | 41787 | 41787   | 41787 | 1       |
| deployRentalUnit                                   | $${\color{green}70670}$$ | $${\color{orange}1879478}$$ | $${\color{red}2482414}$$ | 2482414 | 4       |
| deployedContracts                                  | $${\color{green}468}$$   | 468   | 468     | 468   | 1       |

---

**Test Suite Results:**



## Slither Analysis Report

### General Information:

- **Compiled with solc**
- **Total number of contracts in source files:** 9
- **Source lines of code (SLOC) in source files:** 937
- **Number of assembly lines:** 0
- **Number of optimization issues:** 0
- **Number of informational issues:** 63
- **Number of low issues:** 2
- **Number of medium issues:** 0
- **Number of high issues:** 0

### ERC Standards Supported:

- ERC721
- ERC165

### Contract Overview

| **Name**           | **# Functions** | **ERCs**        | **ERC20 Info** | **Complex Code** | **Features**             |
|--------------------|-----------------|-----------------|----------------|------------------|--------------------------|
| **Create2**        | 3               |                 |                | No               | Assembly                |
| **Errors**         | 0               |                 |                | No               |                          |
| **RentalUnit**     | 100             | ERC165, ERC721  |                | Yes              | Receive ETH, Send ETH, Assembly |
| **RentalUnitFactory** | 2             |                 |                | No               |                          |
| **Errors**         | 0               |                 |                | No               |                          |

---

This report provides an overview of the contracts analyzed by Slither, detailing the number of functions, ERC compliance, complex code usage, and specific features for each contract.
