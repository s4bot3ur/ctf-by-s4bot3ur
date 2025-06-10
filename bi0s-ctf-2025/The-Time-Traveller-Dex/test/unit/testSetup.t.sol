//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Setup,DEX,Finance} from "src/Setup.sol";
import {Test,console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";

contract testSetup is Test{
    Setup setup;
    DEX dex;
    Finance finance;
    address WETH;
    address INR;
    function setUp()public{
        setup=new Setup();
        dex= setup.dex();
        finance=setup.finance();
        WETH=address(finance.WETH());
        INR=address(finance.INR());
    }

    function test_Setup_Contract_Sets_EveryThing()public{
        uint256 _reserve0=dex.reserve0();
        uint256 _reserve1=dex.reserve1();
        assertEq(_reserve0,setup.WETH_SUPPLIED_BY_LP());
        assertEq(_reserve1,setup.INR_SUPPLIED_BY_LP());
        console.log("RESERVE 0 :",_reserve0);
        console.log("RESERVE 1 :",_reserve1);
        
    }

    function testSolve()public{
        
    }
}