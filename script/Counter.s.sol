// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/SimplePriceOracle.sol";

contract DeployOracle is Script {
    function run() external {
        // Retrieve private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the oracle
        SimplePriceOracle oracle = new SimplePriceOracle();
        
        // Deploy mock tokens for testing
        // XRP has 6 decimals on XRPL
        MockToken wrappedXRP = new MockToken("Wrapped XRP", "wXRP", 6);
        // xUSD with 6 decimals like other XRPL tokens
        MockToken xUSD = new MockToken("XRPL USD", "xUSD", 6);
        
        // Set initial prices (with 8 decimals for oracle prices)
        // XRP at $0.60
        oracle.updatePrice(address(wrappedXRP), 60000000);
        // xUSD at $1.00
        oracle.updatePrice(address(xUSD), 100000000);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log deployed addresses
        console.log("Deployed Addresses:");
        console.log("------------------");
        console.log("Oracle:", address(oracle));
        console.log("Mock Wrapped XRP:", address(wrappedXRP));
        console.log("Mock xUSD:", address(xUSD));
        
        console.log("\nInitial Prices:");
        console.log("--------------");
        console.log("XRP: $0.60");
        console.log("xUSD: $1.00");
        
        // Save deployment addresses to a file for easy access
        string memory deploymentInfo = string(abi.encodePacked(
            "ORACLE_ADDRESS=", vm.toString(address(oracle)), "\n",
            "WXRP_ADDRESS=", vm.toString(address(wrappedXRP)), "\n",
            "XUSD_ADDRESS=", vm.toString(address(xUSD)), "\n"
        ));
        vm.writeFile("deployments.txt", deploymentInfo);
    }
}

// Helper script for updating prices during demo
contract UpdatePrices is Script {
    function simulateMarketChanges(address oracle) external {
        SimplePriceOracle priceOracle = SimplePriceOracle(oracle);
        
        // Load token addresses (you would get these from your deployments.txt)
        address wrappedXRP = vm.envAddress("WXRP_ADDRESS");

        // Simulate price changes
        priceOracle.updatePrice(wrappedXRP, 65000000);    // XRP up to $0.65
        // xUSD stays at $1.00 as it's a stablecoin
        
        console.log("Updated XRP price to $0.65");
    }

    function simulateMarketCrash(address oracle) external {
        SimplePriceOracle priceOracle = SimplePriceOracle(oracle);
        
        address wrappedXRP = vm.envAddress("WXRP_ADDRESS");

        priceOracle.updatePrice(wrappedXRP, 45000000);    // XRP down to $0.45
        
        console.log("Updated XRP price to $0.45");
    }
}