//SPDX-License-Identifier-MIT
pragma solidity ^0.8.20;
import "forge-std/StdJson.sol";
import {Script,console} from "forge-std/Script.sol";
import {VasthavikamainaToken} from "src/core/VasthavikamainaToken.sol";
import {IUniswapV2Factory} from "src/uniswap-v2/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "src/uniswap-v2/interfaces/IUniswapV2Pair.sol";
import {WhiteListed} from "src/core/WhiteListed.sol";
import {Factory} from "src/core/Factory.sol";
import {Setup} from "src/core/Setup.sol";
import {LamboToken} from "src/core/LamboToken.sol";
import {WETH9} from "src/core/WETH.sol";
import {Balancer, IFlashLoanRecipient} from "src/core/Balancer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Solve is Script{
    using stdJson for *;
    function run()public{
        string memory path = string.concat("broadcast/Solve.s.sol/", vm.toString(block.chainid), "/run-latest.json");
        try vm.readFile(path){
            string memory json = vm.readFile(path);
            address _exploit = json.readAddress(".transactions[0].contractAddress");
            vm.startBroadcast();
            Exploit exploit= Exploit(_exploit);
            exploit.pwn();
            vm.stopBroadcast();
        }catch{
            string memory path = string.concat("broadcast/Deploy.s.sol/", vm.toString(block.chainid), "/run-latest.json");
            string memory json = vm.readFile(path);
            address setup = json.readAddress(".transactions[0].contractAddress");
            vm.startBroadcast();
            Exploit exploit=new Exploit(setup);
            exploit.pwn();
            vm.stopBroadcast();
        }
        
        
    }
}


contract Exploit{
    Setup public setup;
    Factory public factory;
    WETH9 public wETH9;
    Balancer public balancer;
    WhiteListed public whiteListed;
    constructor(address _setup){
        setup=Setup(_setup);
        wETH9=setup.wETH9();
        balancer=setup.balancer();
        whiteListed=setup.whiteListed();
    }

    function pwn()public{
       
        /*
        YOUR EXPLOIT LOGIC STARTS HERE
        */
        
    }
}


