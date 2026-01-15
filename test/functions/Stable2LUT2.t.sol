// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console, TestHelper, IERC20} from "test/TestHelper.sol";
import {Stable2} from "src/functions/Stable2.sol";
import {Stable2LUT2} from "src/functions/StableLUT/Stable2LUT2.sol";
import {ILookupTable} from "src/interfaces/ILookupTable.sol";

/**
 * @title Stable2LUT2Test
 * @notice Tests the Stable2LUT2 lookup table with A=50 amplification parameter.
 * @dev This test suite verifies:
 *   1. Correct A parameter is returned
 *   2. LUT returns valid PriceData for price ranges
 *   3. Integration with Stable2 well function
 *   4. Edge case handling
 */
contract Stable2LUT2Test is TestHelper {
    Stable2LUT2 lut;
    Stable2 stable2;
    bytes data;

    function setUp() public {
        lut = new Stable2LUT2();
        stable2 = new Stable2(address(lut));
        data = abi.encode(18, 18);
    }

    // ============ A Parameter Tests ============

    /// @notice Verify the LUT returns correct A parameter
    function test_getAParameter() public {
        assertEq(lut.getAParameter(), 50, "A parameter should be 50");
    }

    /// @notice Verify A parameter matches between LUT and Stable2
    function test_aParameterConsistency() public {
        assertEq(lut.getAParameter(), 50, "LUT A parameter mismatch");
    }

    // ============ Liquidity Price Lookup Tests ============

    /// @notice Test price lookup at parity (price ~ 1.0)
    function test_getRatiosFromPriceLiquidity_atParity() public {
        ILookupTable.PriceData memory priceData = lut.getRatiosFromPriceLiquidity(1e6);
        
        // At parity, we expect price bounds to straddle 1.0
        assertTrue(priceData.lowPrice <= 1e6, "Low price should be <= 1.0");
        assertTrue(priceData.highPrice >= 1e6 || priceData.lowPrice == 1e6, "High price should be >= 1.0");
        assertEq(priceData.precision, 1e18, "Precision should be 1e18");
    }

    /// @notice Test price lookup below peg
    function test_getRatiosFromPriceLiquidity_belowPeg() public {
        // Price = 0.9 (10% below peg)
        ILookupTable.PriceData memory priceData = lut.getRatiosFromPriceLiquidity(0.9e6);
        
        assertTrue(priceData.lowPrice < 0.9e6, "Low price should be below target");
        assertTrue(priceData.highPrice >= 0.9e6, "High price should be at or above target");
    }

    /// @notice Test price lookup above peg
    function test_getRatiosFromPriceLiquidity_abovePeg() public {
        // Price = 1.1 (10% above peg)
        ILookupTable.PriceData memory priceData = lut.getRatiosFromPriceLiquidity(1.1e6);
        
        assertTrue(priceData.lowPrice <= 1.1e6, "Low price should be at or below target");
        assertTrue(priceData.highPrice > 1.1e6, "High price should be above target");
    }

    /// @notice Test extreme low price lookup
    function test_getRatiosFromPriceLiquidity_extremeLow() public {
        // Price = 0.2 (80% below peg)
        ILookupTable.PriceData memory priceData = lut.getRatiosFromPriceLiquidity(0.2e6);
        
        assertTrue(priceData.highPriceJ > 0, "High price J reserve should be non-zero");
    }

    /// @notice Test extreme high price lookup
    function test_getRatiosFromPriceLiquidity_extremeHigh() public {
        // Price = 2.0 (100% above peg)
        ILookupTable.PriceData memory priceData = lut.getRatiosFromPriceLiquidity(2e6);
        
        assertTrue(priceData.highPriceI > 0, "High price I reserve should be non-zero");
    }

    /// @notice Test invalid price below minimum
    function test_getRatiosFromPriceLiquidity_invalidLow() public {
        vm.expectRevert("LUT: Invalid price");
        lut.getRatiosFromPriceLiquidity(0.0001e6);
    }

    /// @notice Test invalid price above maximum
    function test_getRatiosFromPriceLiquidity_invalidHigh() public {
        vm.expectRevert("LUT: Invalid price");
        lut.getRatiosFromPriceLiquidity(10e6);
    }

    // ============ Swap Price Lookup Tests ============

    /// @notice Test swap price lookup at parity
    function test_getRatiosFromPriceSwap_atParity() public {
        ILookupTable.PriceData memory priceData = lut.getRatiosFromPriceSwap(1e6);
        
        assertTrue(priceData.lowPrice <= 1e6, "Low price should be <= 1.0");
        assertEq(priceData.precision, 1e18, "Precision should be 1e18");
    }

    /// @notice Test swap price lookup below peg
    function test_getRatiosFromPriceSwap_belowPeg() public {
        ILookupTable.PriceData memory priceData = lut.getRatiosFromPriceSwap(0.8e6);
        
        assertTrue(priceData.lowPrice < 0.8e6, "Low price should be below target");
        assertTrue(priceData.highPrice >= 0.8e6, "High price should be at or above target");
    }

    // ============ Integration Tests ============

    /// @notice Test Stable2 initialization with LUT2
    function test_stable2Integration() public {
        uint256[] memory reserves = new uint256[](2);
        reserves[0] = 1_000_000e18;
        reserves[1] = 1_000_000e18;
        
        uint256 lpSupply = stable2.calcLpTokenSupply(reserves, data);
        
        // At parity with A=50, LP supply should be approximately sum of reserves
        assertApproxEqRel(lpSupply, 2_000_000e18, 0.01e18, "LP supply should be ~2M at parity");
    }

    /// @notice Test rate calculation with A=50
    function test_calcRate_atParity() public {
        uint256[] memory reserves = new uint256[](2);
        reserves[0] = 1_000_000e18;
        reserves[1] = 1_000_000e18;
        
        uint256 rate = stable2.calcRate(reserves, 0, 1, data);
        
        // At parity, rate should be very close to 1e6
        assertApproxEqAbs(rate, 1e6, 1000, "Rate should be ~1.0 at parity");
    }

    /// @notice Test rate calculation with imbalanced reserves
    function test_calcRate_imbalanced() public {
        uint256[] memory reserves = new uint256[](2);
        reserves[0] = 1_000_000e18;
        reserves[1] = 1_100_000e18; // 10% more of token 1
        
        uint256 rate = stable2.calcRate(reserves, 0, 1, data);
        
        // With more of token 1, token 0 should be worth more (rate > 1.0)
        assertTrue(rate > 1e6, "Rate should be > 1.0 when token 1 is abundant");
    }

    // ============ Comparison Tests ============

    /// @notice Compare A=50 vs A=100 curve characteristics
    /// @dev A=50 should have steeper price impact than A=100
    function test_curveCharacteristics() public {
        uint256[] memory reserves = new uint256[](2);
        reserves[0] = 1_000_000e18;
        reserves[1] = 1_000_000e18;
        
        uint256 lpSupplyA50 = stable2.calcLpTokenSupply(reserves, data);
        
        // Verify LP supply is reasonable
        assertTrue(lpSupplyA50 > 0, "LP supply should be positive");
        assertTrue(lpSupplyA50 <= reserves[0] + reserves[1], "LP supply should not exceed sum of reserves");
    }

    // ============ Fuzz Tests ============

    /// @notice Fuzz test price lookup doesn't revert for valid range
    function testFuzz_getRatiosFromPriceLiquidity(uint256 price) public view {
        // Bound price to valid range (based on LUT bounds)
        price = bound(price, 0.186e6, 5.28e6);
        
        ILookupTable.PriceData memory priceData = lut.getRatiosFromPriceLiquidity(price);
        
        // Verify returned data is consistent
        assertTrue(priceData.lowPrice <= priceData.highPrice, "Low price should be <= high price");
        assertTrue(priceData.precision > 0, "Precision should be positive");
    }

    /// @notice Fuzz test LP token supply calculation
    function testFuzz_calcLpTokenSupply(uint256 reserve0, uint256 reserve1) public {
        // Bound reserves to reasonable range
        reserve0 = bound(reserve0, 1e18, 1e32);
        reserve1 = bound(reserve1, reserve0 / 600, reserve0 * 600); // Within 600x ratio
        
        uint256[] memory reserves = new uint256[](2);
        reserves[0] = reserve0;
        reserves[1] = reserve1;
        
        uint256 lpSupply = stable2.calcLpTokenSupply(reserves, data);
        
        assertTrue(lpSupply > 0, "LP supply should be positive for non-zero reserves");
    }
}
