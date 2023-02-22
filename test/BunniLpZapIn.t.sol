// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

import "../src/BunniLpZapIn.sol";

contract BunniLpZapInTest is Test {
    BunniLpZapIn zap;
    ERC20 constant token0 = ERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e); // FRAX
    ERC20 constant token1 = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC
    ILiquidityGauge constant gauge = ILiquidityGauge(0x471A34823DDd9506fe8dFD6BC5c2890e4114Fafe);

    function setUp() public {
        zap = new BunniLpZapIn({
            zeroExProxy_: 0xDef1C0ded9bec7F1a1670819833240f027b25EfF,
            weth_: WETH(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)),
            bunniHub_: IBunniHub(0xb5087F95643A9a4069471A28d32C569D9bd57fE4)
        });

        // approve tokens
        token0.approve(address(zap), type(uint256).max);
        token1.approve(address(zap), type(uint256).max);
    }

    function test_basicAdd() external {
        uint256 amount0Desired = 1e18;
        uint256 amount1Desired = 1.77e18;

        // mint tokens
        deal(address(token0), address(this), amount0Desired);
        deal(address(token1), address(this), amount1Desired);

        (uint256 shares,,,) = zap.zapIn(
            IBunniHub.DepositParams({
                key: BunniKey({
                    pool: IUniswapV3Pool(0x9A834b70C07C81a9fcD6F22E842BF002fBfFbe4D),
                    tickLower: -276331,
                    tickUpper: -276327
                }),
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp,
                recipient: address(0)
            }),
            gauge,
            token0,
            token1,
            address(this),
            0,
            false,
            false,
            false
        );

        assertEq(gauge.balanceOf(address(this)), shares, "didn't receive gauge shares");
        assertEq(token0.balanceOf(address(zap)), 0, "zap has token0 balance");
        assertEq(token1.balanceOf(address(zap)), 0, "zap has token1 balance");
    }

    function test_basicAddUsingContractBalance() external {
        uint256 amount0Desired = 1e18;
        uint256 amount1Desired = 1.77e18;

        // mint tokens
        deal(address(token0), address(zap), amount0Desired);
        deal(address(token1), address(zap), amount1Desired);

        (uint256 shares,,,) = zap.zapIn(
            IBunniHub.DepositParams({
                key: BunniKey({
                    pool: IUniswapV3Pool(0x9A834b70C07C81a9fcD6F22E842BF002fBfFbe4D),
                    tickLower: -276331,
                    tickUpper: -276327
                }),
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp,
                recipient: address(0)
            }),
            gauge,
            token0,
            token1,
            address(this),
            0,
            true,
            true,
            false
        );

        assertEq(gauge.balanceOf(address(this)), shares, "didn't receive gauge shares");
        assertEq(token0.balanceOf(address(zap)), 0, "zap has token0 balance");
        assertEq(token1.balanceOf(address(zap)), 0, "zap has token1 balance");
    }

    function test_basicAddWithCompound() external {
        uint256 amount0Desired = 1e18;
        uint256 amount1Desired = 1.77e18;

        // mint tokens
        deal(address(token0), address(this), amount0Desired);
        deal(address(token1), address(this), amount1Desired);

        (uint256 shares,,,) = zap.zapIn(
            IBunniHub.DepositParams({
                key: BunniKey({
                    pool: IUniswapV3Pool(0x9A834b70C07C81a9fcD6F22E842BF002fBfFbe4D),
                    tickLower: -276331,
                    tickUpper: -276327
                }),
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp,
                recipient: address(0)
            }),
            gauge,
            token0,
            token1,
            address(this),
            0,
            false,
            false,
            true
        );

        assertEq(gauge.balanceOf(address(this)), shares, "didn't receive gauge shares");
        assertEq(token0.balanceOf(address(zap)), 0, "zap has token0 balance");
        assertEq(token1.balanceOf(address(zap)), 0, "zap has token1 balance");
    }
}