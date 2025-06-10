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
            vm.stopBroadcast();
        }catch{
            vm.startBroadcast();
            // This snippet might help you to script your exploit in an easier way
            vm.stopBroadcast();
        }
        
        
    }

}


contract Exploit{
    address WETH;
    address INR;
    DEX dex;
    Finance public finance;
    
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
       /* 
        *STEP 1 Exploit Logic 
        *There will be some other steps along with this that you need to code in order to solve this challenge. 
        Also, a small hint I can give is that the challenge cannot be solved within a single transaction. So the above code
        in run() might also help you. Try to utilize everything and make your exploit as minimal as possible :)
        */
    }


}  





