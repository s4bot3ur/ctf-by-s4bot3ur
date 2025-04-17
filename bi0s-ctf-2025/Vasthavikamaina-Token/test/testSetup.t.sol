pragma solidity ^0.8.20;

import {VasthavikamainaToken} from "src/core/VasthavikamainaToken.sol";
import {IUniswapV2Factory} from "src/uniswap-v2/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "src/uniswap-v2/interfaces/IUniswapV2Pair.sol";
import {WhiteListed} from "src/core/WhiteListed.sol";
import {Factory} from "src/core/Factory.sol";
import {Setup} from "src/core/Setup.sol";
import {Test,console} from "forge-std/Test.sol";
import {LamboToken} from "src/core/LamboToken.sol";
import {WETH9} from "src/core/WETH.sol";
import {Balancer,IFlashLoanRecipient} from "src/core/Balancer.sol";

contract testFactory is Test{
    address owner=makeAddr("OWNER");
    address LP=makeAddr("LIQUIDITY__PROVIDIER");
    VasthavikamainaToken public VSTETH;
    IUniswapV2Factory public uniswapV2Factory;
    WhiteListed public whilteListed;
    Factory public factory;
    WETH9 public wETH9;
    Balancer public _balancer;
    IUniswapV2Pair public uniPair1;
    IUniswapV2Pair public uniPair2;
    IUniswapV2Pair public uniPair3;
    LamboToken public lamboToken1;
    LamboToken public lamboToken2;
    LamboToken public lamboToken3;
    Setup public chall_Setup;

    address _factory=address(0x5FbDB2315678afecb367f032d93F642f64180aa3);

    function setUp()public{
        startHoax(owner);
        chall_Setup =new Setup{value: 6.35 ether}(_factory);
        VSTETH=chall_Setup.VSTETH();
        uniswapV2Factory=chall_Setup.uniswapV2Factory();
        whilteListed=chall_Setup.whilteListed();
        factory=chall_Setup.factory();
        uniPair1=chall_Setup.uniPair1();
        uniPair2=chall_Setup.uniPair2();
        uniPair3=chall_Setup.uniPair3();
        lamboToken1=chall_Setup.lamboToken1();
        lamboToken2=chall_Setup.lamboToken2();
        lamboToken3=chall_Setup.lamboToken3();
        wETH9=chall_Setup.wETH9();
        _balancer=chall_Setup._balancer();
        vm.stopPrank();
    }

    modifier depositInWETH(){
        startHoax(LP);
        wETH9.deposit{value: 32560203560896180352774}(LP);
        vm.stopPrank();
        _;
    }

    function test_Chal_Setup()public depositInWETH{
        uint256 _balance=lamboToken1.balanceOf(address(chall_Setup));
        console.log(_balance);
        _balance=lamboToken2.balanceOf(address(chall_Setup));
        console.log(_balance);
        _balance=lamboToken3.balanceOf(address(chall_Setup));
        console.log(_balance);
    }

    function test_FlashLoanWorks()public depositInWETH{

    }

}

