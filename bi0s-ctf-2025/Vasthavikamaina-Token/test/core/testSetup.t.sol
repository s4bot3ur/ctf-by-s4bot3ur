//SPDX-License-Identifier-MIT
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
import {Balancer, IFlashLoanRecipient} from "src/core/Balancer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
    uint256 _liquidityAmount = 32560203560896180352774;

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
        _balancer=chall_Setup.balancer();
        vm.stopPrank();
    }

    modifier depositInWETH(){
        startHoax(LP);
        wETH9.deposit{value: _liquidityAmount}(LP);
        wETH9.approve(address(_balancer), _liquidityAmount);
        _balancer.provideLiquidity(address(wETH9), _liquidityAmount);
        vm.stopPrank();
        _;
    }

    modifier maketxs(){
        //3.255690356089618e+22 vETH-HBL
        uint256 _vETHBalanceTo_VETH_BIF=132513467878004258374 - (3e18+3e17);
        whilteListed.buyQuote{value: _vETHBalanceTo_VETH_BIF}(address(lamboToken1), _vETHBalanceTo_VETH_BIF, 0);
        _;
        

    }

    function test_Chal_Setup()public depositInWETH maketxs{
        uint256 _balance=lamboToken1.balanceOf(address(chall_Setup));
        console.log(_balance);
        _balance=lamboToken2.balanceOf(address(chall_Setup));
        console.log(_balance);
        _balance=lamboToken3.balanceOf(address(chall_Setup));
        console.log(_balance);
    }

    function testExploit()public depositInWETH maketxs{
        FlashLoanReceiver _flashloanReceiver=new FlashLoanReceiver();
        IERC20[] memory _tokens=new IERC20[](1);
        _tokens[0]=IERC20(address(wETH9));
        uint256[] memory _amounts=new uint256[](1);
        _amounts[0]=_liquidityAmount;
        bytes memory _data;
        _balancer.flashloan(_flashloanReceiver, _tokens, _amounts, _data);
    }

}

contract FlashLoanReceiver is IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory _tokens,
        uint256[] memory _amounts,
        uint256[] memory _feeAmounts,
        bytes memory _data
    ) external override {
        IERC20 _token=_tokens[0];
        uint256 _amount=_amounts[0];
        }
    
}

