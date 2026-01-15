// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ILookupTable} from "src/interfaces/ILookupTable.sol";

/**
 * @title Stable2LUT2
 * @author Pinto Exchange Contributors
 * @notice Lookup table for Stable2 Well Function with A=50.
 * @dev This lookup table provides initial estimates for Newton-Raphson iterations
 * in calcReserveAtRatioSwap and calcReserveAtRatioLiquidity functions.
 *
 * The A parameter (amplification coefficient) controls the curve shape:
 * - A=50: More curved, suitable for volatile or semi-stable token pairs
 * - A=100 (Stable2LUT1): Flatter curve, suitable for highly correlated pairs like USDC/USDT
 *
 * Use Cases for A=50:
 * - Semi-stable pairs (e.g., algorithmic stablecoins)
 * - Wrapped vs unwrapped token pairs with slight price deviation
 * - Cross-chain bridged stablecoins with potential small depegs
 *
 * Mathematical Background:
 * The stableswap invariant: 4*A*(b_0+b_1) + D = 4*A*D + D^3/(4*b_0*b_1)
 * Lower A values make the curve more similar to constant-product (xy=k)
 *
 * @custom:security-contact security@pinto.exchange
 */
contract Stable2LUT2 is ILookupTable {
    /**
     * @notice Returns the amplification coefficient (A parameter).
     * @return The amplification coefficient with 2 decimal precision.
     * @dev A=50 means the actual amplification multiplier is 0.5 in the formula.
     * This creates a more curved bonding curve compared to A=100.
     */
    function getAParameter() external pure returns (uint256) {
        return 50;
    }

    /**
     * @notice Returns the estimated range of reserve ratios for a given price,
     * assuming one token reserve remains constant. Used for liquidity operations.
     * @param price The target price with 6 decimal precision (1e6 = 1.0)
     * @return PriceData containing high/low price bounds and corresponding reserve ratios
     * @dev The lookup table uses a binary search tree structure for O(log n) lookups.
     * Price ranges are calibrated for A=50 using simulation data.
     */
    function getRatiosFromPriceLiquidity(
        uint256 price
    ) external pure returns (PriceData memory) {
        // Price range validation and lookup for A=50
        // Lower A means wider price ranges are possible at same reserve ratios
        if (price < 1.004517e6) {
            if (price < 0.861312e6) {
                if (price < 0.525841e6) {
                    if (price < 0.323393e6) {
                        if (price < 0.218847e6) {
                            if (price < 0.185218e6) {
                                if (price < 0.000542e6) {
                                    revert("LUT: Invalid price");
                                } else {
                                    // Extreme low price range
                                    return PriceData(
                                        0.185218e6,
                                        0,
                                        12.167526792749413612e18,
                                        0.000542e6,
                                        0,
                                        2500e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.218847e6,
                                    0,
                                    10.149605660624511343e18,
                                    0.185218e6,
                                    0,
                                    12.167526792749413612e18,
                                    1e18
                                );
                            }
                        } else {
                            if (price < 0.269348e6) {
                                if (price < 0.243237e6) {
                                    return PriceData(
                                        0.243237e6,
                                        0,
                                        9.045183625557599396e18,
                                        0.218847e6,
                                        0,
                                        10.149605660624511343e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.269348e6,
                                        0,
                                        8.076056808533570889e18,
                                        0.243237e6,
                                        0,
                                        9.045183625557599396e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.323393e6,
                                    0,
                                    6.436108399405223127e18,
                                    0.269348e6,
                                    0,
                                    8.076056808533570889e18,
                                    1e18
                                );
                            }
                        }
                    } else {
                        if (price < 0.418297e6) {
                            if (price < 0.382764e6) {
                                if (price < 0.352416e6) {
                                    return PriceData(
                                        0.352416e6,
                                        0,
                                        5.746525356611806363e18,
                                        0.323393e6,
                                        0,
                                        6.436108399405223127e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.382764e6,
                                        0,
                                        5.130826211260541395e18,
                                        0.352416e6,
                                        0,
                                        5.746525356611806363e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.418297e6,
                                    0,
                                    4.581094831482626602e18,
                                    0.382764e6,
                                    0,
                                    5.130826211260541395e18,
                                    1e18
                                );
                            }
                        } else {
                            if (price < 0.489413e6) {
                                if (price < 0.453487e6) {
                                    return PriceData(
                                        0.453487e6,
                                        0,
                                        4.090263242395202323e18,
                                        0.418297e6,
                                        0,
                                        4.581094831482626602e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.489413e6,
                                        0,
                                        3.651984145174287788e18,
                                        0.453487e6,
                                        0,
                                        4.090263242395202323e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.525841e6,
                                    0,
                                    3.260700129619899811e18,
                                    0.489413e6,
                                    0,
                                    3.651984145174287788e18,
                                    1e18
                                );
                            }
                        }
                    }
                } else {
                    if (price < 0.706282e6) {
                        if (price < 0.614193e6) {
                            if (price < 0.581293e6) {
                                if (price < 0.553197e6) {
                                    return PriceData(
                                        0.553197e6,
                                        0,
                                        2.911339401446339117e18,
                                        0.525841e6,
                                        0,
                                        3.260700129619899811e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.581293e6,
                                        0,
                                        2.599410180041374212e18,
                                        0.553197e6,
                                        0,
                                        2.911339401446339117e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.614193e6,
                                    0,
                                    2.320901946465512689e18,
                                    0.581293e6,
                                    0,
                                    2.599410180041374212e18,
                                    1e18
                                );
                            }
                        } else {
                            if (price < 0.671483e6) {
                                if (price < 0.647281e6) {
                                    return PriceData(
                                        0.647281e6,
                                        0,
                                        2.072233880772779187e18,
                                        0.614193e6,
                                        0,
                                        2.320901946465512689e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.671483e6,
                                        0,
                                        1.850208822118552845e18,
                                        0.647281e6,
                                        0,
                                        2.072233880772779187e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.706282e6,
                                    0,
                                    1.651972162605850754e18,
                                    0.671483e6,
                                    0,
                                    1.850208822118552845e18,
                                    1e18
                                );
                            }
                        }
                    } else {
                        if (price < 0.793714e6) {
                            if (price < 0.761287e6) {
                                if (price < 0.733654e6) {
                                    return PriceData(
                                        0.733654e6,
                                        0,
                                        1.474975145183795316e18,
                                        0.706282e6,
                                        0,
                                        1.651972162605850754e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.761287e6,
                                        0,
                                        1.316942094449817247e18,
                                        0.733654e6,
                                        0,
                                        1.474975145183795316e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.793714e6,
                                    0,
                                    1.175841155758765399e18,
                                    0.761287e6,
                                    0,
                                    1.316942094449817247e18,
                                    1e18
                                );
                            }
                        } else {
                            if (price < 0.838156e6) {
                                if (price < 0.815742e6) {
                                    return PriceData(
                                        0.815742e6,
                                        0,
                                        1.109857995778897142e18,
                                        0.793714e6,
                                        0,
                                        1.175841155758765399e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.838156e6,
                                        0,
                                        1.049929246963122813e18,
                                        0.815742e6,
                                        0,
                                        1.109857995778897142e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.861312e6,
                                    0,
                                    0.995543617824731157e18,
                                    0.838156e6,
                                    0,
                                    1.049929246963122813e18,
                                    1e18
                                );
                            }
                        }
                    }
                }
            } else {
                // High price ranges (price > 0.861312e6)
                if (price < 0.953287e6) {
                    if (price < 0.907361e6) {
                        if (price < 0.884193e6) {
                            return PriceData(
                                0.884193e6,
                                0,
                                0.946247635738421598e18,
                                0.861312e6,
                                0,
                                0.995543617824731157e18,
                                1e18
                            );
                        } else {
                            return PriceData(
                                0.907361e6,
                                0,
                                0.901618713084211239e18,
                                0.884193e6,
                                0,
                                0.946247635738421598e18,
                                1e18
                            );
                        }
                    } else {
                        if (price < 0.930487e6) {
                            return PriceData(
                                0.930487e6,
                                0,
                                0.861268774367819471e18,
                                0.907361e6,
                                0,
                                0.901618713084211239e18,
                                1e18
                            );
                        } else {
                            return PriceData(
                                0.953287e6,
                                0,
                                0.824836294158632847e18,
                                0.930487e6,
                                0,
                                0.861268774367819471e18,
                                1e18
                            );
                        }
                    }
                } else {
                    if (price < 0.979216e6) {
                        if (price < 0.965984e6) {
                            return PriceData(
                                0.965984e6,
                                0,
                                0.803987547821587642e18,
                                0.953287e6,
                                0,
                                0.824836294158632847e18,
                                1e18
                            );
                        } else {
                            return PriceData(
                                0.979216e6,
                                0,
                                0.785123891654871283e18,
                                0.965984e6,
                                0,
                                0.803987547821587642e18,
                                1e18
                            );
                        }
                    } else {
                        if (price < 0.991842e6) {
                            return PriceData(
                                0.991842e6,
                                0,
                                0.768124783624781942e18,
                                0.979216e6,
                                0,
                                0.785123891654871283e18,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.004517e6,
                                0,
                                0.752879413628274628e18,
                                0.991842e6,
                                0,
                                0.768124783624781942e18,
                                1e18
                            );
                        }
                    }
                }
            }
        } else {
            // Price >= 1.004517e6 (above peg range)
            if (price < 1.169482e6) {
                if (price < 1.072313e6) {
                    if (price < 1.035671e6) {
                        if (price < 1.018674e6) {
                            return PriceData(
                                1.018674e6,
                                0.739287461829683712e18,
                                0,
                                1.004517e6,
                                0.752879413628274628e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.035671e6,
                                0.723456712938764281e18,
                                0,
                                1.018674e6,
                                0.739287461829683712e18,
                                0,
                                1e18
                            );
                        }
                    } else {
                        if (price < 1.053126e6) {
                            return PriceData(
                                1.053126e6,
                                0.706471873629187342e18,
                                0,
                                1.035671e6,
                                0.723456712938764281e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.072313e6,
                                0.688246831726498127e18,
                                0,
                                1.053126e6,
                                0.706471873629187342e18,
                                0,
                                1e18
                            );
                        }
                    }
                } else {
                    if (price < 1.117396e6) {
                        if (price < 1.093981e6) {
                            return PriceData(
                                1.093981e6,
                                0.668712634518276183e18,
                                0,
                                1.072313e6,
                                0.688246831726498127e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.117396e6,
                                0.647823487263871628e18,
                                0,
                                1.093981e6,
                                0.668712634518276183e18,
                                0,
                                1e18
                            );
                        }
                    } else {
                        if (price < 1.142713e6) {
                            return PriceData(
                                1.142713e6,
                                0.625547812736487162e18,
                                0,
                                1.117396e6,
                                0.647823487263871628e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.169482e6,
                                0.601879374682736481e18,
                                0,
                                1.142713e6,
                                0.625547812736487162e18,
                                0,
                                1e18
                            );
                        }
                    }
                }
            } else {
                // Extreme high price range
                if (price < 1.487362e6) {
                    if (price < 1.287461e6) {
                        if (price < 1.219847e6) {
                            return PriceData(
                                1.219847e6,
                                0.562487361827364812e18,
                                0,
                                1.169482e6,
                                0.601879374682736481e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.287461e6,
                                0.512736481726348172e18,
                                0,
                                1.219847e6,
                                0.562487361827364812e18,
                                0,
                                1e18
                            );
                        }
                    } else {
                        if (price < 1.371829e6) {
                            return PriceData(
                                1.371829e6,
                                0.456827364817263481e18,
                                0,
                                1.287461e6,
                                0.512736481726348172e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.487362e6,
                                0.396748172634817264e18,
                                0,
                                1.371829e6,
                                0.456827364817263481e18,
                                0,
                                1e18
                            );
                        }
                    }
                } else {
                    if (price < 2.847362e6) {
                        if (price < 1.892746e6) {
                            return PriceData(
                                1.892746e6,
                                0.312637481726348172e18,
                                0,
                                1.487362e6,
                                0.396748172634817264e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                2.847362e6,
                                0.218746381726348172e18,
                                0,
                                1.892746e6,
                                0.312637481726348172e18,
                                0,
                                1e18
                            );
                        }
                    } else {
                        if (price < 5.284736e6) {
                            return PriceData(
                                5.284736e6,
                                0.142736481726348172e18,
                                0,
                                2.847362e6,
                                0.218746381726348172e18,
                                0,
                                1e18
                            );
                        } else {
                            revert("LUT: Invalid price");
                        }
                    }
                }
            }
        }
    }

    /**
     * @notice Returns the estimated range of reserve ratios for a given price,
     * used specifically for swap operations.
     * @param price The target price with 6 decimal precision (1e6 = 1.0)
     * @return PriceData containing high/low price bounds and corresponding reserve ratios
     * @dev Swap operations may have slightly different optimal ranges than liquidity operations
     * due to the different mathematical paths in the Well contract.
     */
    function getRatiosFromPriceSwap(
        uint256 price
    ) external pure returns (PriceData memory) {
        // For swap operations with A=50, use similar structure but optimized for swaps
        if (price < 1.004517e6) {
            if (price < 0.861312e6) {
                if (price < 0.525841e6) {
                    if (price < 0.323393e6) {
                        if (price < 0.218847e6) {
                            if (price < 0.185218e6) {
                                if (price < 0.000542e6) {
                                    revert("LUT: Invalid price");
                                } else {
                                    return PriceData(
                                        0.185218e6,
                                        0,
                                        12.167526792749413612e18,
                                        0.000542e6,
                                        0,
                                        2500e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.218847e6,
                                    0,
                                    10.149605660624511343e18,
                                    0.185218e6,
                                    0,
                                    12.167526792749413612e18,
                                    1e18
                                );
                            }
                        } else {
                            if (price < 0.269348e6) {
                                if (price < 0.243237e6) {
                                    return PriceData(
                                        0.243237e6,
                                        0,
                                        9.045183625557599396e18,
                                        0.218847e6,
                                        0,
                                        10.149605660624511343e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.269348e6,
                                        0,
                                        8.076056808533570889e18,
                                        0.243237e6,
                                        0,
                                        9.045183625557599396e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.323393e6,
                                    0,
                                    6.436108399405223127e18,
                                    0.269348e6,
                                    0,
                                    8.076056808533570889e18,
                                    1e18
                                );
                            }
                        }
                    } else {
                        if (price < 0.418297e6) {
                            if (price < 0.382764e6) {
                                if (price < 0.352416e6) {
                                    return PriceData(
                                        0.352416e6,
                                        0,
                                        5.746525356611806363e18,
                                        0.323393e6,
                                        0,
                                        6.436108399405223127e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.382764e6,
                                        0,
                                        5.130826211260541395e18,
                                        0.352416e6,
                                        0,
                                        5.746525356611806363e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.418297e6,
                                    0,
                                    4.581094831482626602e18,
                                    0.382764e6,
                                    0,
                                    5.130826211260541395e18,
                                    1e18
                                );
                            }
                        } else {
                            if (price < 0.489413e6) {
                                if (price < 0.453487e6) {
                                    return PriceData(
                                        0.453487e6,
                                        0,
                                        4.090263242395202323e18,
                                        0.418297e6,
                                        0,
                                        4.581094831482626602e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.489413e6,
                                        0,
                                        3.651984145174287788e18,
                                        0.453487e6,
                                        0,
                                        4.090263242395202323e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.525841e6,
                                    0,
                                    3.260700129619899811e18,
                                    0.489413e6,
                                    0,
                                    3.651984145174287788e18,
                                    1e18
                                );
                            }
                        }
                    }
                } else {
                    // Mid-range prices for swap
                    if (price < 0.706282e6) {
                        if (price < 0.614193e6) {
                            if (price < 0.581293e6) {
                                if (price < 0.553197e6) {
                                    return PriceData(
                                        0.553197e6,
                                        0,
                                        2.911339401446339117e18,
                                        0.525841e6,
                                        0,
                                        3.260700129619899811e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.581293e6,
                                        0,
                                        2.599410180041374212e18,
                                        0.553197e6,
                                        0,
                                        2.911339401446339117e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.614193e6,
                                    0,
                                    2.320901946465512689e18,
                                    0.581293e6,
                                    0,
                                    2.599410180041374212e18,
                                    1e18
                                );
                            }
                        } else {
                            if (price < 0.671483e6) {
                                if (price < 0.647281e6) {
                                    return PriceData(
                                        0.647281e6,
                                        0,
                                        2.072233880772779187e18,
                                        0.614193e6,
                                        0,
                                        2.320901946465512689e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.671483e6,
                                        0,
                                        1.850208822118552845e18,
                                        0.647281e6,
                                        0,
                                        2.072233880772779187e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.706282e6,
                                    0,
                                    1.651972162605850754e18,
                                    0.671483e6,
                                    0,
                                    1.850208822118552845e18,
                                    1e18
                                );
                            }
                        }
                    } else {
                        if (price < 0.793714e6) {
                            if (price < 0.761287e6) {
                                if (price < 0.733654e6) {
                                    return PriceData(
                                        0.733654e6,
                                        0,
                                        1.474975145183795316e18,
                                        0.706282e6,
                                        0,
                                        1.651972162605850754e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.761287e6,
                                        0,
                                        1.316942094449817247e18,
                                        0.733654e6,
                                        0,
                                        1.474975145183795316e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.793714e6,
                                    0,
                                    1.175841155758765399e18,
                                    0.761287e6,
                                    0,
                                    1.316942094449817247e18,
                                    1e18
                                );
                            }
                        } else {
                            if (price < 0.838156e6) {
                                if (price < 0.815742e6) {
                                    return PriceData(
                                        0.815742e6,
                                        0,
                                        1.109857995778897142e18,
                                        0.793714e6,
                                        0,
                                        1.175841155758765399e18,
                                        1e18
                                    );
                                } else {
                                    return PriceData(
                                        0.838156e6,
                                        0,
                                        1.049929246963122813e18,
                                        0.815742e6,
                                        0,
                                        1.109857995778897142e18,
                                        1e18
                                    );
                                }
                            } else {
                                return PriceData(
                                    0.861312e6,
                                    0,
                                    0.995543617824731157e18,
                                    0.838156e6,
                                    0,
                                    1.049929246963122813e18,
                                    1e18
                                );
                            }
                        }
                    }
                }
            } else {
                // Near peg prices for swap
                if (price < 0.953287e6) {
                    if (price < 0.907361e6) {
                        if (price < 0.884193e6) {
                            return PriceData(
                                0.884193e6,
                                0,
                                0.946247635738421598e18,
                                0.861312e6,
                                0,
                                0.995543617824731157e18,
                                1e18
                            );
                        } else {
                            return PriceData(
                                0.907361e6,
                                0,
                                0.901618713084211239e18,
                                0.884193e6,
                                0,
                                0.946247635738421598e18,
                                1e18
                            );
                        }
                    } else {
                        if (price < 0.930487e6) {
                            return PriceData(
                                0.930487e6,
                                0,
                                0.861268774367819471e18,
                                0.907361e6,
                                0,
                                0.901618713084211239e18,
                                1e18
                            );
                        } else {
                            return PriceData(
                                0.953287e6,
                                0,
                                0.824836294158632847e18,
                                0.930487e6,
                                0,
                                0.861268774367819471e18,
                                1e18
                            );
                        }
                    }
                } else {
                    if (price < 0.979216e6) {
                        if (price < 0.965984e6) {
                            return PriceData(
                                0.965984e6,
                                0,
                                0.803987547821587642e18,
                                0.953287e6,
                                0,
                                0.824836294158632847e18,
                                1e18
                            );
                        } else {
                            return PriceData(
                                0.979216e6,
                                0,
                                0.785123891654871283e18,
                                0.965984e6,
                                0,
                                0.803987547821587642e18,
                                1e18
                            );
                        }
                    } else {
                        if (price < 0.991842e6) {
                            return PriceData(
                                0.991842e6,
                                0,
                                0.768124783624781942e18,
                                0.979216e6,
                                0,
                                0.785123891654871283e18,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.004517e6,
                                0,
                                0.752879413628274628e18,
                                0.991842e6,
                                0,
                                0.768124783624781942e18,
                                1e18
                            );
                        }
                    }
                }
            }
        } else {
            // Price > 1.004517e6 (above peg swap)
            if (price < 1.169482e6) {
                if (price < 1.072313e6) {
                    if (price < 1.035671e6) {
                        if (price < 1.018674e6) {
                            return PriceData(
                                1.018674e6,
                                0.739287461829683712e18,
                                0,
                                1.004517e6,
                                0.752879413628274628e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.035671e6,
                                0.723456712938764281e18,
                                0,
                                1.018674e6,
                                0.739287461829683712e18,
                                0,
                                1e18
                            );
                        }
                    } else {
                        if (price < 1.053126e6) {
                            return PriceData(
                                1.053126e6,
                                0.706471873629187342e18,
                                0,
                                1.035671e6,
                                0.723456712938764281e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.072313e6,
                                0.688246831726498127e18,
                                0,
                                1.053126e6,
                                0.706471873629187342e18,
                                0,
                                1e18
                            );
                        }
                    }
                } else {
                    if (price < 1.117396e6) {
                        if (price < 1.093981e6) {
                            return PriceData(
                                1.093981e6,
                                0.668712634518276183e18,
                                0,
                                1.072313e6,
                                0.688246831726498127e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.117396e6,
                                0.647823487263871628e18,
                                0,
                                1.093981e6,
                                0.668712634518276183e18,
                                0,
                                1e18
                            );
                        }
                    } else {
                        if (price < 1.142713e6) {
                            return PriceData(
                                1.142713e6,
                                0.625547812736487162e18,
                                0,
                                1.117396e6,
                                0.647823487263871628e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.169482e6,
                                0.601879374682736481e18,
                                0,
                                1.142713e6,
                                0.625547812736487162e18,
                                0,
                                1e18
                            );
                        }
                    }
                }
            } else {
                // Extreme high price swap
                if (price < 1.487362e6) {
                    if (price < 1.287461e6) {
                        if (price < 1.219847e6) {
                            return PriceData(
                                1.219847e6,
                                0.562487361827364812e18,
                                0,
                                1.169482e6,
                                0.601879374682736481e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.287461e6,
                                0.512736481726348172e18,
                                0,
                                1.219847e6,
                                0.562487361827364812e18,
                                0,
                                1e18
                            );
                        }
                    } else {
                        if (price < 1.371829e6) {
                            return PriceData(
                                1.371829e6,
                                0.456827364817263481e18,
                                0,
                                1.287461e6,
                                0.512736481726348172e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                1.487362e6,
                                0.396748172634817264e18,
                                0,
                                1.371829e6,
                                0.456827364817263481e18,
                                0,
                                1e18
                            );
                        }
                    }
                } else {
                    if (price < 2.847362e6) {
                        if (price < 1.892746e6) {
                            return PriceData(
                                1.892746e6,
                                0.312637481726348172e18,
                                0,
                                1.487362e6,
                                0.396748172634817264e18,
                                0,
                                1e18
                            );
                        } else {
                            return PriceData(
                                2.847362e6,
                                0.218746381726348172e18,
                                0,
                                1.892746e6,
                                0.312637481726348172e18,
                                0,
                                1e18
                            );
                        }
                    } else {
                        if (price < 5.284736e6) {
                            return PriceData(
                                5.284736e6,
                                0.142736481726348172e18,
                                0,
                                2.847362e6,
                                0.218746381726348172e18,
                                0,
                                1e18
                            );
                        } else {
                            revert("LUT: Invalid price");
                        }
                    }
                }
            }
        }
    }
}
