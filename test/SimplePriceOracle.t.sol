// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SimplePriceOracle.sol";

contract SimplePriceOracleTest is Test {
    SimplePriceOracle public oracle;
    MockToken public wrappedXRP;
    MockToken public xUSD;

    address public admin = address(1);
    address public user = address(2);

    function setUp() public {
        // Deploy oracle and set admin
        oracle = new SimplePriceOracle();
        oracle.transferOwnership(admin);

        // Deploy mock tokens
        wrappedXRP = new MockToken("Wrapped XRP", "wXRP", 6);
        xUSD = new MockToken("XRPL USD", "xUSD", 6);

        // Set initial prices as admin
        vm.startPrank(admin);

        // Set XRP price to $0.60
        oracle.updatePrice(address(wrappedXRP), 60000000);

        // Set xUSD price to $1.00
        oracle.updatePrice(address(xUSD), 100000000);

        vm.stopPrank();
    }

    function test_GetPrices() public view {
        assertEq(oracle.getPrice(address(wrappedXRP)), 60000000, "Wrong XRP price");
        assertEq(oracle.getPrice(address(xUSD)), 100000000, "Wrong xUSD price");
    }

    function test_UpdatePrice() public {
        vm.startPrank(admin);

        // XRP drops to $0.55
        oracle.updatePrice(address(wrappedXRP), 55000000);

        vm.stopPrank();

        assertEq(oracle.getPrice(address(wrappedXRP)), 55000000, "Wrong XRP price after update");
    }

    function test_BatchUpdate() public {
        vm.startPrank(admin);

        address[] memory tokens = new address[](2);
        tokens[0] = address(wrappedXRP);
        tokens[1] = address(xUSD);

        uint256[] memory prices = new uint256[](2);
        prices[0] = 65000000; // XRP to $0.65
        prices[1] = 100000000; // xUSD stays at $1.00

        oracle.batchUpdatePrices(tokens, prices);

        vm.stopPrank();

        assertEq(oracle.getPrice(address(wrappedXRP)), 65000000, "Wrong XRP price after batch update");
        assertEq(oracle.getPrice(address(xUSD)), 100000000, "Wrong xUSD price after batch update");
    }

    function test_RevertWhen_UnauthorizedUpdate() public {
        vm.startPrank(user);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        oracle.updatePrice(address(wrappedXRP), 55000000);

        vm.stopPrank();
    }

    function test_RevertWhen_GettingInvalidPrice() public {
        vm.expectRevert(abi.encodeWithSelector(SimplePriceOracle.PriceNotSet.selector, address(3)));
        oracle.getPrice(address(3));
    }

    function test_HasPriceSet() public view {
        assertTrue(oracle.hasPriceSet(address(wrappedXRP)), "XRP price should be set");
        assertTrue(oracle.hasPriceSet(address(xUSD)), "xUSD price should be set");
        assertFalse(oracle.hasPriceSet(address(3)), "Random address should not have price set");
    }
}
