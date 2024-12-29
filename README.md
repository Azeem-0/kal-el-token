# Kal-El Token Smart Contract

## Overview
The KalEl Token is a capped, ERC-20-like token implemented in Solidity. It includes features like minting, burning, pausing, transferring ownership, and standard ERC-20 operations. The contract is designed to provide secure and efficient token management with additional functionalities.

## Features
- **Minting**: Only the owner can mint new tokens, respecting the capped supply limit.
- **Burning**: Tokens can be burned to reduce the total supply, only the owner can burn tokens.
- **Pausing**: The owner can pause or unpause token operations.
- **Ownership Transfer**: Ownership of the contract can be transferred.
- **ERC-20 Standard Operations**: Includes `transfer`, `approve`,`balanceOf`,`allowance` and `transferFrom` functions.

## Prerequisites
- Solidity ^0.8.28
- An Ethereum development environment (e.g., Hardhat)
- Node.js and npm (for testing and deployment)



## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Azeem-0/kal-el-token.git
   ```

2. Navigate to the project directory:

   ```bash
   cd kal-el-token
   ```

3. Install dependencies:

   ```bash
   npm install
   ```

4. Set up environment variables:

   Create a `.env` file in the root directory and add the following:

   ```env
   PRIVATE_KEY=<your_private_key>
   INFURA_API_KEY=<your_infura_api_key>
   ```

5. Compile the contract: 

   ```bash
   npx hardhat compile
   ```

6. Run the tests:

   ```bash
   npx hardhat test   
   ```
6. Deploy the contract using Hardhat:

   ```bash
   npx hardhat run scripts/deploy.js --network <your_preferred_network>  
   ```




## Deployment
### Constructor Parameters
The constructor requires the following parameters:
1. `uint256 initialSupply`: Initial supply of tokens.
2. `string tokenName`: Name of the token.
3. `string tokenSymbol`: Symbol of the token.
4. `uint256 totalCappedSupply`: Maximum capped supply of tokens.
5. `uint8 decimals`: Number of decimals for the token.

#### Example:
```solidity
constructor(
    uint256 _initialSupply,
    string memory _tokenName,
    string memory _tokenSymbol,
    uint256 _totalCappedSupply,
    uint8 _decimals
)
```




## Functions
### Core ERC-20 Functions
- `transfer(address to, uint256 amount)`: Transfer tokens to given address.
- `approve(address spender, uint256 amount)`: Approve allowance to `spender` address.
- `transferFrom(address from, address to, uint256 amount)`: Transfer from given `from` address to `to` address
- `allowance(address owner, address spender)`: Check Allowance for `spender` from `owner` address

### Owner-Only Functions
- `mint(address to, uint256 amount)`: Mint new tokens into the given address.
- `burn(address from, uint256 amount)`: Burn tokens from the given address.
- `pause()`: Pause token operations.
- `unpause()`: Unpause token operations.
- `transferOwnership(address newOwner)`: Transfer owner to `newOwner` address.

### View Functions
- `name()`: Returns the name of the token.
- `symbol()`: Returns the symbol of the token.
- `getDecimals()`: Returns the number of decimals.
- `getTotalSupply()`: Returns the total supply.
- `getOwner()`: Returns the owner address.
- `balanceOf(address account)`: Returns balance of the account.

## Events
- `Transfer(address indexed from, address indexed to, uint256 value)`
- `Approval(address indexed owner, address indexed spender, uint256 value)`
- `Paused(address account)`
- `Unpaused(address account)`
- `Mint(address indexed to, uint256 value)`
- `Burn(address indexed from, uint256 value)`
- `OwnershipTransferred(address indexed previousOwner, address indexed newOwner)`


## Security Considerations
- **Owner-Only Functions** : The functions that are intended to be restricted to the owner (such as minting, burning, pausing, and transferring ownership) are made public in this contract for testing purposes only. In a production environment, these functions should be restricted to the owner using modifiers like onlyOwner to prevent unauthorized access.
- Proper checks are in place to ensure the capped supply limit is respected.
- Address validation ensures no zero-address operations.
