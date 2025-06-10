//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {Setup,Stake,INR} from "src/Setup.sol";
import "forge-std/StdJson.sol"; 

contract Solve is Script{
    using stdJson for *;
    error Challenge__Unsolved();
    function run()public{
        Setup setup;
        Stake stake;
        INR inr;
        string memory Setup_path=string.concat("broadcast/Deploy.s.sol/", vm.toString(block.chainid), "/run-latest.json");
        try vm.readFile(Setup_path){
            string memory json = vm.readFile(Setup_path);
            address deployed = json.readAddress(".transactions[0].contractAddress");
            setup=Setup(deployed);
            stake=setup.stake();
            inr=setup.inr();
        }catch{
            revert("Chall Not Yet Deployed");
        }
        vm.startBroadcast();
        Exploit exploit=new Exploit(setup);
        exploit.pwn();
        if(!setup.isSolved()){
            revert Challenge__Unsolved();
        }
        vm.stopBroadcast();

    }
}   


contract Exploit{
    Stake stake;
    INR inr;
    Setup setup;

    constructor(Setup _setup){
        setup=_setup;
        inr=setup.inr();
        stake=setup.stake();
    }

    function pwn()public{
        /*
        YOUR EXPLOIT LOGIC STARTS HERE
        */
    }
}