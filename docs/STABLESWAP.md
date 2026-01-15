# Stable2 Well Function Documentation

## Overview

The Stable2 Well Function implements a two-token stableswap curve optimized for like-valued assets. This documentation covers the mathematical foundations, implementation details, and usage guidelines for the Stable2 system.

## Table of Contents

1. [Mathematical Foundation](#mathematical-foundation)
2. [Architecture](#architecture)
3. [Lookup Tables (LUT)](#lookup-tables-lut)
4. [Usage Examples](#usage-examples)
5. [Gas Optimization](#gas-optimization)
6. [Security Considerations](#security-considerations)

---

## Mathematical Foundation

### The Stableswap Invariant

The Stable2 function uses a modified stableswap curve that balances between constant-sum and constant-product behavior:

```
4A(b_0 + b_1) + D = 4AD + D^3 / (4 * b_0 * b_1)
```

Where:
- **A** = Amplification coefficient (controls curve shape)
- **D** = LP token supply (the invariant)
- **b_0, b_1** = Token reserves

### Amplification Coefficient (A)

The A parameter determines how closely the curve behaves to different AMM models:

| A Value | Curve Behavior | Use Case |
|---------|---------------|----------|
| A -> 0 | Constant Product (xy=k) | High volatility pairs |
| A = 50 | Hybrid curve | Semi-stable pairs |
| A = 100 | Moderate stableswap | Standard stablecoins |
| A -> inf | Constant Sum (x+y=k) | Perfect peg pairs |

### Price Calculation

The exchange rate between tokens is calculated using the derivative of the invariant:

```
rate = delta_reserve_i / delta_reserve_j
```

Where we increment reserve_j by a small amount (PRICE_PRECISION = 1e6) and solve for the new reserve_i.

### Newton-Raphson Iteration

Both calcLpTokenSupply and calcReserve use Newton-Raphson iteration for convergence:

**LP Token Supply (D):**
```
D[n+1] = (4A * sum(b) + D_p * N) * D[n] / ((4A - 1) * D[n] + (N+1) * D_p)

where D_p = D^N / (N^N * prod(b_i))
```

**Reserve Calculation:**
```
x[n+1] = (x[n]^2 + c) / (2 * x[n] + b - D)

where:
  c = D^3 / (4 * N * A * b_other)
  b = b_other + D / (4 * A)
```

---

## Architecture

### Contract Structure

```
src/
├── functions/
│   ├── Stable2.sol              # Main stableswap implementation
│   ├── ProportionalLPToken2.sol # LP token math for 2-token wells
│   └── StableLUT/
│       ├── Stable2LUT1.sol      # Lookup table for A=100
│       └── Stable2LUT2.sol      # Lookup table for A=50
├── interfaces/
│   ├── IWellFunction.sol        # Base well function interface
│   ├── ILookupTable.sol         # LUT interface
│   └── IBeanstalkWellFunction.sol # Extended interface
```

### Key Interfaces

#### IWellFunction
```solidity
interface IWellFunction {
    function calcLpTokenSupply(
        uint256[] memory reserves,
        bytes calldata data
    ) external view returns (uint256 lpTokenSupply);
    
    function calcReserve(
        uint256[] memory reserves,
        uint256 j,
        uint256 lpTokenSupply,
        bytes calldata data
    ) external view returns (uint256 reserve);
    
    function calcLPTokenUnderlying(
        uint256 lpTokenAmount,
        uint256[] memory reserves,
        uint256 lpTokenSupply,
        bytes calldata data
    ) external view returns (uint256[] memory underlyingAmounts);
}
```

#### ILookupTable
```solidity
interface ILookupTable {
    struct PriceData {
        uint256 highPrice;      // Upper bound price
        uint256 highPriceI;     // Reserve i at high price
        uint256 highPriceJ;     // Reserve j at high price
        uint256 lowPrice;       // Lower bound price
        uint256 lowPriceI;      // Reserve i at low price
        uint256 lowPriceJ;      // Reserve j at low price
        uint256 precision;      // Scaling precision (typically 1e18)
    }
    
    function getAParameter() external view returns (uint256);
    function getRatiosFromPriceLiquidity(uint256 price) external view returns (PriceData memory);
    function getRatiosFromPriceSwap(uint256 price) external view returns (PriceData memory);
}
```

---

## Lookup Tables (LUT)

### Purpose

Lookup tables provide initial estimates for Newton-Raphson iterations in calcReserveAtRatioSwap and calcReserveAtRatioLiquidity. Without good initial estimates, these functions would require many more iterations (or fail to converge).

### Available LUTs

| Contract | A Parameter | Use Case |
|----------|-------------|----------|
| Stable2LUT1 | 100 | Highly correlated stablecoin pairs (USDC/USDT) |
| Stable2LUT2 | 50 | Semi-stable pairs, algorithmic stables, bridged tokens |

### Creating New LUTs

To create a LUT for a different A parameter:

1. **Run the simulation script:**
```bash
forge script script/simulations/stableswap/StableswapCalcRatiosLiqSim.s.sol
```

2. **Use the Python generator (for documentation):**
```bash
python script/generators/generate_lut.py --a-parameter 200 --output Stable2LUT3.sol
```

3. **Verify the LUT covers your price range requirements**

### LUT Data Structure

The LUT uses a binary search tree structure encoded in nested if-else statements:

```solidity
function getRatiosFromPriceLiquidity(uint256 price) external pure returns (PriceData memory) {
    if (price < 1.0e6) {
        if (price < 0.5e6) {
            // Low price range
        } else {
            // Near-peg low
        }
    } else {
        // Above peg
    }
}
```

This achieves O(log n) lookup complexity with minimal gas overhead.

---

## Usage Examples

### Creating a Stable2 Well

```solidity
import {Stable2} from "src/functions/Stable2.sol";
import {Stable2LUT1} from "src/functions/StableLUT/Stable2LUT1.sol";

// Deploy LUT first
address lut = address(new Stable2LUT1());

// Deploy Stable2 with LUT
Stable2 wellFunction = new Stable2(lut);

// Create well with the function
// (See Well.sol for full well creation)
```

### Calculating LP Token Supply

```solidity
uint256[] memory reserves = new uint256[](2);
reserves[0] = 1_000_000e18; // 1M Token A
reserves[1] = 1_000_000e18; // 1M Token B

// Data encodes decimals: (tokenA decimals, tokenB decimals)
bytes memory data = abi.encode(18, 18);

uint256 lpSupply = stable2.calcLpTokenSupply(reserves, data);
// lpSupply ~ 2_000_000e18 (sum at parity)
```

### Calculating Exchange Rate

```solidity
// Get the exchange rate of Token A in terms of Token B
uint256 rate = stable2.calcRate(reserves, 0, 1, data);
// rate = 1_000_000 (1e6 precision) when at parity
```

### Finding Reserve at Target Ratio

```solidity
// For Beanstalk integration - find reserve to reach target price
uint256[] memory ratios = new uint256[](2);
ratios[0] = 1e18;    // Target ratio for token 0
ratios[1] = 1.01e18; // Target ratio for token 1 (1% premium)

uint256 newReserve = stable2.calcReserveAtRatioSwap(
    reserves,
    1,        // Solve for reserve[1]
    ratios,
    data
);
```

### Different Token Decimals

```solidity
// USDC (6 decimals) / DAI (18 decimals) pair
reserves[0] = 1_000_000e6;   // 1M USDC
reserves[1] = 1_000_000e18;  // 1M DAI

bytes memory data = abi.encode(6, 18);

uint256 lpSupply = stable2.calcLpTokenSupply(reserves, data);
```

---

## Gas Optimization

### Iteration Limits

Both calcLpTokenSupply and calcReserve limit iterations to 255:

```solidity
for (uint256 i = 0; i < 255; i++) {
    // Newton-Raphson iteration
    if (convergenceCheck) return result;
}
revert("Non convergence");
```

Typical convergence:
- **At parity**: 4-8 iterations
- **10% imbalance**: 8-15 iterations
- **Extreme imbalance**: 20-50 iterations

### LUT Optimization

The binary search tree structure in LUTs provides:
- **Lookup complexity**: O(log n) comparisons
- **Gas cost**: ~2,000-4,000 gas per lookup
- **No storage reads**: All data is in contract bytecode

### Decimal Scaling

Reserves are scaled to 18 decimals internally:
```solidity
scaledReserves[i] = reserves[i] * 10 ** (18 - decimals[i]);
```

This ensures consistent precision regardless of input token decimals.

---

## Security Considerations

### Precision Loss

1. **Rounding Direction**: calcReserve rounds up to favor the protocol
2. **Minimum Reserves**: Extremely small reserves (<1e12 scaled) may lose precision
3. **Price Threshold**: Convergence threshold is 0.001% (PRICE_THRESHOLD = 10)

### Invariant Constraints

The key invariant must always hold:
```
totalSupply() <= calcLpTokenSupply(reserves, data)
```

This ensures LP tokens can always be redeemed.

### Edge Cases

| Scenario | Behavior |
|----------|----------|
| Zero reserves | Returns 0 LP supply |
| Single zero reserve | May revert or return edge case |
| Extreme imbalance (>20x) | May not converge |
| Price outside LUT range | Reverts with "LUT: Invalid price" |

### Reentrancy

The Stable2 contract is stateless and does not hold funds. Reentrancy protection is handled by the Well contract.

---

## Integration Checklist

- [ ] Choose appropriate LUT for your A parameter
- [ ] Verify token decimals are <= 18
- [ ] Test with expected reserve ranges
- [ ] Handle "Non convergence" reverts gracefully
- [ ] Verify price range is within LUT bounds
- [ ] Consider gas costs for on-chain calculations

---

## References

- [Curve Finance Stableswap Whitepaper](https://curve.fi/files/stableswap-paper.pdf)
- [Basin Documentation](https://docs.basin.exchange)
- [Pinto Exchange Docs](https://docs.pinto.exchange)

---

*Last updated: January 2026*
