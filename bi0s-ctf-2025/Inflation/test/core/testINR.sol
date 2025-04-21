//SPDX-License-Identifier-MIT
pragma solidity ^0.8.20;

import {Test,console} from "forge-std/Test.sol";
import {INR} from "src/INR.sol";
contract testINR is Test{
    error MyError();
    error MyErrorWithValue(uint256);
    INR inr;
    uint256 INR_INITIAL_SUPPLY=100e18;
    address owner=makeAddr("OWNER");
    address tokenReceiver=makeAddr("TOKEN RECEIVER");
    function setUp()public{
        hoax(owner);
        inr=new INR(INR_INITIAL_SUPPLY,"INR","INR");
    }


    function testBalanceOf()public{
        startHoax(owner);
        uint256 _balance=inr.balanceOf(owner);
        console.log(_balance);
    }


    function testTransfer()public{
        startHoax(owner);
        uint256 _balance=inr.balanceOf(owner);
        vm.expectRevert(abi.encodeWithSelector(INR.InsufficientBalance.selector,_balance,_balance+1e18));
        // Transfer more than owner holding fails
        inr.transfer(tokenReceiver, _balance+1e18);
        inr.transfer(tokenReceiver, _balance);
        assertEq(inr.balanceOf(tokenReceiver),_balance);
        assertEq(inr.balanceOf(owner),0);
        vm.stopPrank();
    }

    function test_approve_and_allowance()public{
        startHoax(owner);
        inr.approve(tokenReceiver, 100e18);
        assertEq(inr.allowance(owner, tokenReceiver),100e18);
        console.log(inr.allowance(owner, tokenReceiver));
        vm.stopPrank();
    }


    function testTransferFrom()public{
        uint256 _aprooveAmount=100e18;
        hoax(owner);
        inr.approve(tokenReceiver, _aprooveAmount);
        startHoax(tokenReceiver);
        //Spending more than allowance reverts
        vm.expectRevert(abi.encodeWithSelector(INR.InsufficientAllowance.selector,100e18, 101e18));
        inr.transferFrom(owner, tokenReceiver, 101e18);

        // Allowance and balance update correctly after transfer
        uint256 _transferAmount=50e18;
        uint256 _allowanceBefore=inr.allowance(owner, tokenReceiver);
        uint256 _ownerBalanceBefore=inr.balanceOf(owner);
        uint256 _tokenReceiverBalanceBefore=inr.balanceOf(tokenReceiver);

        inr.transferFrom(owner, tokenReceiver, _transferAmount);
        uint256 _ownerBalanceAfter=inr.balanceOf(owner);
        uint256 _tokenReceiverBalanceAfter=inr.balanceOf(tokenReceiver);
        
        assertEq(inr.allowance(owner, tokenReceiver),_allowanceBefore-_transferAmount);
        assertEq(inr.balanceOf(owner),_ownerBalanceBefore-_ownerBalanceAfter);
        assertEq(inr.balanceOf(tokenReceiver),_tokenReceiverBalanceAfter-_tokenReceiverBalanceBefore);

        // When spender try to spend more than owner balance it should revert
        uint256 _tokenReceiverBalance=inr.balanceOf(tokenReceiver);        
        inr.approve(owner, _tokenReceiverBalance*2);
        vm.stopPrank();
        startHoax(owner);
        uint256 _allowance=inr.allowance(tokenReceiver, owner);
        vm.expectRevert(abi.encodeWithSelector(INR.InsufficientBalance.selector,inr.balanceOf(tokenReceiver),_allowance));
        inr.transferFrom(tokenReceiver, owner,_allowance);
    }

    function test_total_supply_increases_After_Mint()public{
        uint256 mint_Amount=10e18;
        startHoax(owner);
        //Since no token minted after contract created the totalSupply should be initial supply
        assertEq(inr.totalSupply(),INR_INITIAL_SUPPLY);
        inr.mint(tokenReceiver, mint_Amount);
        assertEq(inr.totalSupply(),INR_INITIAL_SUPPLY+mint_Amount);
        console.log(inr.totalSupply());
    }
    
    function test_Batch_Transfer()public{
        startHoax(owner);

        // Testing a normal batch transfer with proper storage updates
        address receiver1=makeAddr("RECEIVER-1");
        address receiver2=makeAddr("RECEIVER-2");
        address[] memory receivers=new address[](2);
        uint256 transferAmount=10e18;
        receivers[0]=receiver1;
        receivers[1]=receiver2;
        uint256 _ownerBalanceBefore=inr.balanceOf(owner);
        inr.batchTransfer(receivers, transferAmount);
        assertEq(inr.balanceOf(receiver1),transferAmount);
        assertEq(inr.balanceOf(receiver2),transferAmount);
        assertEq(inr.balanceOf(owner),_ownerBalanceBefore-(transferAmount *2));
        /* When user balance less than total address * amount the function should 
        revert with Insuffficient Balance */
    
        uint256 _currentBalance=inr.balanceOf(address(owner));
        transferAmount=_currentBalance;
        vm.expectRevert(abi.encodeWithSelector(INR.InsufficientBalance.selector,_currentBalance, transferAmount*2));
        inr.batchTransfer(receivers, transferAmount);

        vm.stopPrank();
    }

    function testBatchTransferOverflow()public{
        startHoax(owner);
        address receiver1=makeAddr("RECEIVER-1");
        address receiver2=makeAddr("RECEIVER-2");
        address[] memory receivers=new address[](2);
        receivers[0]=receiver1;
        receivers[1]=receiver2;
        uint256 transferAmount=((type(uint256).max)/2)+1;
        inr.batchTransfer(receivers, transferAmount);
        console.log("OWNER BALANCE     :",inr.balanceOf(owner));
        console.log("RECEIVER1 BALANCE :",inr.balanceOf(receiver1));
        console.log("RECEIVER2 BALANCE :",inr.balanceOf(receiver1));

        // When the user balance is zero then batchtransferOverflow doesnt work

        address tester=makeAddr("TESTER");
        startHoax(tester);
        vm.expectRevert(abi.encodeWithSelector(INR.INR__Zero__Balance.selector));
        inr.batchTransfer(receivers, transferAmount);
        

    }

    function test_Only_Owner_Can_Mint()public{
        address nonOwner=makeAddr("NON OWNER");
        uint256 mintAmount=100e18;
        console.log(nonOwner);
        hoax(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(INR.OwnableUnauthorizedAccount.selector, nonOwner));
        inr.mint(nonOwner, mintAmount);

        hoax(owner);
        inr.mint(nonOwner, mintAmount);
        console.log(inr.balanceOf(nonOwner));
        assertEq(inr.balanceOf(nonOwner),mintAmount);
    }


    function test_Only_Owner_Can_Burn()public{
        uint256 mintAmount=100e18;
        uint256 _tokenReceiverBalanceBefore=inr.balanceOf(tokenReceiver);
        hoax(owner);
        inr.mint(tokenReceiver, mintAmount);
        
        address nonOwner=makeAddr("NON OWNER");
        hoax(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(INR.OwnableUnauthorizedAccount.selector, nonOwner));
        inr.burn(tokenReceiver, mintAmount);

        hoax(owner);
        inr.burn(tokenReceiver, mintAmount);
        assertEq(inr.balanceOf(tokenReceiver),_tokenReceiverBalanceBefore);

        startHoax(owner);
        uint256 _currentBalance=inr.balanceOf(tokenReceiver);
        vm.expectRevert(abi.encodeWithSelector(INR.InsufficientBalance.selector,_currentBalance, mintAmount));
        inr.burn(tokenReceiver, mintAmount);
        vm.stopPrank();
    }

    function test_Mint_Increase_Total_Supply_And_Burn_Decrease_TotalSupply()public{
        assertEq(inr.totalSupply(),INR_INITIAL_SUPPLY);
        startHoax(owner);
        uint256 amount=100e18;
        inr.mint(tokenReceiver, amount);
        assertEq(inr.totalSupply(),INR_INITIAL_SUPPLY+amount);
        inr.burn(tokenReceiver, amount);
        assertEq(inr.totalSupply(),INR_INITIAL_SUPPLY);
    }


    function test_name_and_symbol()public{
        inr.name();
    }
}
