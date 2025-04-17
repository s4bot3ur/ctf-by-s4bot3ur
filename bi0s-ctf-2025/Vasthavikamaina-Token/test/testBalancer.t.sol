pragma solidity ^0.8.20;

import {Setup} from "src/core/Setup.sol";
import {Test, console} from "forge-std/Test.sol";
import {WETH9} from "src/core/WETH.sol";
import {Balancer, IFlashLoanRecipient} from "src/core/Balancer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract testBalancer is Test {
    address owner = makeAddr("OWNER");
    address LP = makeAddr("LIQUIDITY__PROVIDIER");
    WETH9 public wETH9;
    Balancer public _balancer;
    uint256 _liquidityAmount = 32560203560896180352774;
    function setUp() public {
        startHoax(owner);
        wETH9 = new WETH9();
        _balancer = new Balancer();
        _balancer.approveToken(address(wETH9));
        vm.stopPrank();
    }

    modifier AddLiquidity() {
        startHoax(LP);
        wETH9.deposit{value: _liquidityAmount}(LP);
        wETH9.approve(address(_balancer), _liquidityAmount);
        _balancer.provideLiquidity(address(wETH9), _liquidityAmount);
        vm.stopPrank();
        _;
    }

    function test_flashloan() public AddLiquidity {
        FlashLoanReceiver _flashloanReceiver =new FlashLoanReceiver();
        IERC20[] memory _tokens=new IERC20[](1);
        uint256[] memory _amounts=new uint256[](1);
        bytes memory _data;
        _tokens[0]=IERC20(address(wETH9));
        _amounts[0]=_liquidityAmount;
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
        for (uint8 i = 0; i < _tokens.length; i++) {
            IERC20(_tokens[i]).transfer(
                msg.sender,
                _feeAmounts[i] + _amounts[i]
            );
            console.log("Token:",address(_tokens[i]));
            console.log("Amounts :",_amounts[i]);
        }
    }
}

