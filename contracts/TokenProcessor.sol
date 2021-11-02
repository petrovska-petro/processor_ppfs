// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "interfaces/IERC20.sol";
import "interfaces/ISettV4.sol";
import "interfaces/ICurveExchange.sol";

contract TokenProcessor {
    // ===== Peak Registry =====
    address public constant badgerSettPeak =
        0x41671BA1abcbA387b9b2B752c205e22e916BE6e3;

    // ===== Token Registry =====
    IERC20 public constant wbtcToken =
        IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 public constant crv_lp_renBTC =
        IERC20(0x49849C98ae39Fff122806C06791Fa73784FB3675);
    IERC20 public constant crv_lp_sBTC =
        IERC20(0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3);

    // ===== Pool Registry =====
    ICurveExchange public constant crvRenBTC =
        ICurveExchange(0x93054188d876f558f4a66B2EF1d97d16eDf0895B);
    ICurveExchange public constant crvSBTC =
        ICurveExchange(0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714);

    // ===== Sett Registry =====
    ISettV4 public constant bcrvRenBTC =
        ISettV4(0x6dEf55d2e18486B9dDfaA075bc4e4EE0B28c1545);
    ISettV4 public constant bcrvSBTC =
        ISettV4(0xd04c48A53c111300aD41190D63681ed3dAd998eC);

    // ===== keeper address =====
    address public keeper;

    // ===== Events =====
    event Injected(
        address indexed peakAddress,
        uint256 wbtcAmount,
        uint256 lpAmount,
        uint256 indexed blockNumber,
        uint256 timestamp
    );

    constructor(address _keeper) public {
        keeper = _keeper;

        // max approvals for common flows - add liq in pool
        wbtcToken.approve(address(crvRenBTC), type(uint256).max);
        wbtcToken.approve(address(crvSBTC), type(uint256).max);

        // max approvals for flow - deposit in sett for
        crv_lp_renBTC.approve(address(bcrvRenBTC), type(uint256).max);
        crv_lp_sBTC.approve(address(bcrvSBTC), type(uint256).max);
    }

    /// @notice set the keeper who will call the ppfs increaser method at determine frequency
    function setKeeper(address _keeper) external {
        _onlyKeeper();
        keeper = _keeper;
    }

    /**
     * @dev only set two viables path for increasing ppfs as tBTC sett would be more gas intensive route
     * @param _routeOption chooses the route to take to increase ppfs (0 -> bcrvRenBTC & 1 -> bcrvSBTC)
     **/
    function increasePpfs(uint256 _routeOption) external {
        _onlyKeeper();

        uint256 wbtcBalance = wbtcToken.balanceOf(address(this));
        uint256 lpBalance;

        if (_routeOption == 0) {
            uint256[2] memory amounts = [0, wbtcBalance];
            crvRenBTC.add_liquidity(amounts, 0);

            lpBalance = crv_lp_renBTC.balanceOf(address(this));

            bcrvRenBTC.depositFor(badgerSettPeak, lpBalance);
        } else if (_routeOption == 1) {
            uint256[3] memory amounts = [0, wbtcBalance, 0];
            crvSBTC.add_liquidity(amounts, 0);

            lpBalance = crv_lp_sBTC.balanceOf(address(this));

            bcrvSBTC.depositFor(badgerSettPeak, 0);
        } else {
            revert("No sett ppfs route available");
        }

        emit Injected(
            badgerSettPeak,
            wbtcBalance,
            lpBalance,
            block.number,
            block.timestamp
        );
    }

    /// INTERNAL FUNCTIONS
    function _onlyKeeper() internal view {
        require(msg.sender == keeper, "Not Keeper!");
    }
}
