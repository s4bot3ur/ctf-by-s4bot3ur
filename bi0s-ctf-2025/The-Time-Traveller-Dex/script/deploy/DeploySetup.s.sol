//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Setup,Finance,DEX} from "src/Setup.sol";

contract DeploySetup is Script{
    Setup setup;
    Finance finance;
    DEX dex;
    address payable player=payable(0xB4135B7cfb875e868FE2fE6faDDd5a150cE9582b);
    function run()public {
        
        vm.startBroadcast();
        setup=new Setup{value : 2_72_500 ether}();
        vm.stopBroadcast();
    }
}   