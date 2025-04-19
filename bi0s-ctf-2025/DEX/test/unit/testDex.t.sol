//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockERC20,ERC20} from "../Mocks/MockERC20.sol"; 
import {Test,console} from "forge-std/Test.sol";
import {DEX} from "src/DEX.sol";


contract testDex is Test{
    address ADMIN=makeAddr("ADMIN");
    DEX public dex;
    ERC20 weth;
    ERC20 usdc;
    address LP=makeAddr("LIQUIDITY PROVIDER");
    address EXPLOITER=makeAddr("EXPLOITER");
    uint256 WETH_SUPPLY_BY_LP=50000e18;
    uint256 USDC_SUPPLY_BY_LP=11500000000e18;

    function setUp()public{
        startHoax(ADMIN);
        dex=new DEX();
        weth=new MockERC20("Wrapped ETHER","WETH",5000000000e18);
        usdc=new MockERC20("Indian Rupee","INR",11500000000000000e18);
        dex.initialize(address(weth), address(usdc));
        vm.stopPrank();
    }

    modifier mint_Tokens_To_LP(){
        startHoax(ADMIN);
        weth.transfer(LP, WETH_SUPPLY_BY_LP);
        usdc.transfer(LP, USDC_SUPPLY_BY_LP);
        vm.stopPrank();
        _;
    }

    modifier mint_Tokens_To_Exploiter(){
        startHoax(ADMIN);  
        weth.transfer(EXPLOITER, WETH_SUPPLY_BY_LP);
        usdc.transfer(EXPLOITER, USDC_SUPPLY_BY_LP);
        vm.stopPrank();
        _;      
    }

 
    function test_Initial_Price_Of_Tokens_In_Pool_Decided_By_Initial_LP()public mint_Tokens_To_LP{
        console.log(dex.price0CumulativeLast());
        console.log(dex.price1CumulativeLast());
        startHoax(LP);
        weth.transfer(address(dex), weth.balanceOf(LP));
        usdc.transfer(address(dex), usdc.balanceOf(LP));
        console.log(dex.mint(LP));
        vm.stopPrank();
        console.log(dex.price0CumulativeLast()>>112);
        console.log((dex.price1CumulativeLast()*4000 * 1e18 )/2**112 );
    }   

    function test_Price_Manipulation_Works()public mint_Tokens_To_Exploiter{
        
        test_Initial_Price_Of_Tokens_In_Pool_Decided_By_Initial_LP();
        console.log(block.timestamp);
        uint256 prev0price=dex.price0CumulativeLast();
        uint256 prev1price=dex.price1CumulativeLast();
        startHoax(EXPLOITER);
        weth.transfer(address(dex), 5e17);
        vm.warp(100);
        console.log(block.timestamp);
        console.log("Balance0 in DEX Before Swap :",weth.balanceOf(address(dex)));
        console.log("Balance1 in DEX Before Swap :",usdc.balanceOf(address(dex)));
        console.log("Transfer in Swap",dex.swap(address(weth), 5e17, 0, EXPLOITER));
        console.log("Balance0 in DEX After Swap :",weth.balanceOf(address(dex)));
        console.log("Balance1 in DEX after Swap :",usdc.balanceOf(address(dex)));
        uint256 current0price=dex.price0CumulativeLast();
        uint256 current1price=dex.price1CumulativeLast();
        console.log(prev0price);
        console.log(prev1price);
        
        console.log("ETH Price after swap",((current0price-prev0price)>>112)/(99));
        console.log(current1price-prev1price);
        vm.stopPrank();
    }


    function test_When_LP_Burns_Tokens_Receives_Same_Number_Of_Tokens_Supplied_By_LP()public{
        test_Initial_Price_Of_Tokens_In_Pool_Decided_By_Initial_LP();
        assertEq(weth.balanceOf(address(dex)),WETH_SUPPLY_BY_LP);
        assertEq(usdc.balanceOf(address(dex)),USDC_SUPPLY_BY_LP);
        startHoax(LP);
        console.log("WETH Balance of DEX before burn =",weth.balanceOf(address(dex)));
        console.log("USDC Balance of DEX before burn =",usdc.balanceOf(address(dex)));
        console.log("WETH Balance of LP before burn =",weth.balanceOf(LP));
        console.log("USDC Balance of LP before burn =",usdc.balanceOf(LP));
        dex.transfer(address(dex), dex.balanceOf(address(LP)));
        dex.burn(LP);
        console.log("WETH Balance of DEX after burn =",weth.balanceOf(address(dex)));
        console.log("USDC Balance of DEX after burn =",usdc.balanceOf(address(dex)));
        console.log("WETH Balance of LP after burn =",weth.balanceOf(LP));
        console.log("USDC Balance of LP after burn =",usdc.balanceOf(LP));
        assertEq(dex.balanceOf(LP),0);
        assertEq(weth.balanceOf(LP),WETH_SUPPLY_BY_LP);
        assertEq(usdc.balanceOf(LP),USDC_SUPPLY_BY_LP);
        assertEq(dex.totalSupply(), 0);
    }


    function test_swap()public mint_Tokens_To_Exploiter{
        test_Initial_Price_Of_Tokens_In_Pool_Decided_By_Initial_LP();
        startHoax(EXPLOITER);
        uint256 _prevBalance=weth.balanceOf(EXPLOITER);
        console.log("USDC DEX BALANCE ",usdc.balanceOf(address(dex)));
        console.log("WETH DEX BALANCE ",weth.balanceOf(address(dex)));
        usdc.transfer(address(dex), 230000e18*50000);
        dex.swap(address(usdc), 230000e18*50000, 0, EXPLOITER);//998003992015968064
        console.log(weth.balanceOf(EXPLOITER)-_prevBalance);
        console.log("USDC DEX BALANCE ",usdc.balanceOf(address(dex)));
        console.log("WETH DEX BALANCE ",weth.balanceOf(address(dex)));
        weth.transfer(address(dex), 25000e18);
        dex.swap(address(weth), 25000e18, 0, EXPLOITER);
        console.log("USDC DEX BALANCE ",usdc.balanceOf(address(dex)));
        console.log("WETH DEX BALANCE ",weth.balanceOf(address(dex)));
        vm.stopPrank();
    }
    
}