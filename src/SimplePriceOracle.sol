// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IPriceOracle {
    event PriceUpdated(address indexed token, uint256 price);
    
    function getPrice(address token) external view returns (uint256);
    function updatePrice(address token, uint256 price) external;
}

contract SimplePriceOracle is IPriceOracle, Ownable {
    constructor() Ownable(msg.sender) {}
    
    mapping(address => uint256) private prices;
    
    error PriceNotSet(address token);
    error InvalidPrice();
    
    /// @notice Get the price of a token
    /// @param token The address of the token
    /// @return The price of the token with 8 decimals (e.g., 100000000 = $1.00)
    function getPrice(address token) external view override returns (uint256) {
        uint256 price = prices[token];
        if (price == 0) revert PriceNotSet(token);
        return price;
    }
    
    /// @notice Update the price of a token
    /// @param token The address of the token
    /// @param price The new price with 8 decimals (e.g., 100000000 = $1.00)
    function updatePrice(address token, uint256 price) external override onlyOwner {
        if (price == 0) revert InvalidPrice();
        if (token == address(0)) revert InvalidPrice();
        
        prices[token] = price;
        emit PriceUpdated(token, price);
    }

    /// @notice Batch update prices for multiple tokens
    /// @param tokens Array of token addresses
    /// @param newPrices Array of prices with 8 decimals
    function batchUpdatePrices(
        address[] calldata tokens,
        uint256[] calldata newPrices
    ) external onlyOwner {
        if (tokens.length != newPrices.length) revert InvalidPrice();
        
        for (uint256 i = 0; i < tokens.length; i++) {
            if (newPrices[i] == 0) revert InvalidPrice();
            if (tokens[i] == address(0)) revert InvalidPrice();
            
            prices[tokens[i]] = newPrices[i];
            emit PriceUpdated(tokens[i], newPrices[i]);
        }
    }

    /// @notice Check if a price is set for a token
    /// @param token The address of the token
    /// @return bool True if price is set
    function hasPriceSet(address token) external view returns (bool) {
        return prices[token] > 0;
    }
}

// Example Mock Token for testing
contract MockToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}