//SPDX-License-Identifier-MIT
pragma solidity ^0.8.20;

import {Setup} from "src/core/Setup.sol";
import {Script,console} from "forge-std/Script.sol";
import {IUniswapV2Factory} from "src/uniswap-v2/interfaces/IUniswapV2Factory.sol";

contract Deploy is Script{

    Setup public _setUp;
    address uniswapFactory=0x5FbDB2315678afecb367f032d93F642f64180aa3;

    function run()public{
        vm.startBroadcast();
        _setUp=new Setup{value: 6.35 ether}(uniswapFactory);
        vm.stopBroadcast();
    }
}