# 🌐 Vastavikamaina Token – CTF Challenge Setup Guide

This guide will help you set up and solve the `Vastavikamaina Token` challenge locally.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Basic understanding of Solidity and smart contracts

## Quick Start

### 1. Start local anvil instance
```bash
make anvil
```
> Starts a local Anvil instance. Make sure to run this in a **new terminal tab/window.**

### 2. Deploy Challenge Contracts
```bash
make deploy
```
> Deploys all challenge contracts to your local blockchain.

### 3. Implement Your Solution
Edit the exploit logic in `script/Solve.s.sol` at the `Exploit:pwn` function:

```solidity
function pwn() public {
    /*
    YOUR EXPLOIT LOGIC STARTS HERE
    */
}
```

### 4. Test Your Solution
```bash
make solve
```
> Executes your solve script against the deployed contracts and checks if the challenge is solved.

### 5. Verify with Author's Solution
```bash
make author-solve
```
> Runs the official solution to verify the challenge setup is working correctly.

## File Structure
```
├── script/
│   ├── Author/
│   │   └──  Solve.s.sol # Author Solution
│   ├── Solve.s.sol      # Your solution goes here
│   └── Deploy.s.sol     # Challenge deployment script
│
├── src/                 # Challenge contracts
├── test/               # Test files
└── Makefile           # Build commands
```

## Challenge Objective

Your goal is to implement the exploit logic in the `pwn()` function that successfully compromises the target contracts and returns the `isSolved()` function in `Setup.sol` to true. Study the contract interactions and find the vulnerability!

## Notes

- If you get stuck, feel free to check my solution in `script/Author/Solve.s.sol:Exploit:pwn`

---

**Happy Hacking! 🎉**