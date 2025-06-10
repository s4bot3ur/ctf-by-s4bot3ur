pragma solidity ^0.8.0;


import {Script,console} from "forge-std/Script.sol";
import {USDS,USDC,WETH,SafeMoon,Setup,USDSEngine} from "src/core/Setup.sol";

import {IBi0sSwapFactory} from "src/bi0s-swap-v1/interfaces/IBi0sSwapFactory.sol";
import {IBi0sSwapPair} from "src/bi0s-swap-v1/interfaces/IBi0sSwapPair.sol";
import "forge-std/StdJson.sol";

contract Solve is Script{


    function run()public{
        string memory path = string.concat("broadcast/Deploy.s.sol/", vm.toString(block.chainid), "/run-latest.json");
        string memory json = vm.readFile(path);
        address setupAddress = json.readAddress(".transactions[0].contractAddress");
        vm.startBroadcast();
        Exploit exploit=new Exploit(setupAddress);
        exploit.pwn();
        vm.stopBroadcast();
    }
}


contract Exploit{

    constructor(){

    }
    function pwn()public{
        /*
        YOUR EXPLOIT LOGIC STARTS HERE
        */
    }
}
