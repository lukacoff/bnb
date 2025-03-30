## BNB

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

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

### GAS Report

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
