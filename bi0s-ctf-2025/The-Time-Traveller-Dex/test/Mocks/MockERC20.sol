//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20{
    constructor(string memory _name, string memory _symbol,uint256 _initial_supply)ERC20(_name,_symbol){
        _mint(msg.sender,_initial_supply);
    }
}