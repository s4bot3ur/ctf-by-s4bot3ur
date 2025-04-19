//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/interfaces/IERC3156FlashBorrower.sol";
import {DEX} from "src/DEX.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Test.sol";

contract test_Flash_Loan is IERC3156FlashBorrower{

    uint256 public lastWethLoanReceived;
    uint256 public lastInrLoanReceived;
    address WETH;
    address INR;

    constructor(address _weth,address _inr){
        WETH=_weth;
        INR=_inr;
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
        IERC20(token).balanceOf(msg.sender);
        IERC20(token).transfer(msg.sender, amount);
        return bytes32(data);
    } 
}
