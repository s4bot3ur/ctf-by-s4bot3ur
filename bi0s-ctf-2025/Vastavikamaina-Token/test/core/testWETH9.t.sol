pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {WETH9} from "src/core/WETH.sol";

contract testWETH9 is Test{
    address LP = makeAddr("LIQUIDITY__PROVIDIER");
    WETH9 wETH9;
    uint256 wETH_DEPOSIT_VALUE=10_000 ether;
    function setUp()public{
        wETH9=new WETH9();
    }

    modifier addLiquidity(){
        startHoax(LP);
        wETH9.deposit{value:wETH_DEPOSIT_VALUE }(LP);
        vm.stopPrank();
        _;
    }


    function test_User_Cant_Transfer_More_Than_Their_Balance()public addLiquidity{
        startHoax(LP);
        address _receiver=makeAddr("RECEIVER");
        vm.expectRevert(abi.encodeWithSelector(WETH9.WETH__Insufficient__Balance.selector,wETH_DEPOSIT_VALUE + 1e18, wETH_DEPOSIT_VALUE));
        wETH9.transfer(_receiver, wETH_DEPOSIT_VALUE+1e18);
        vm.stopPrank();
    }



}