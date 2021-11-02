//  SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface ICurveExchange {
    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external;

    function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amount)
        external;
}
