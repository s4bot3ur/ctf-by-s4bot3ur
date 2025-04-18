pragma solidity ^0.8.20;

import {VasthavikamainaToken} from "src/core/VasthavikamainaToken.sol";
import {LamboToken} from "src/core/LamboToken.sol";
import {Factory} from "src/core/Factory.sol";
import {Test,console} from "forge-std/Test.sol";

contract testFactory is Test{
    Factory _factory;
    VasthavikamainaToken _vasthavikamainaToken;
    LamboToken _lamboToken;

    address OWNER=makeAddr("OWNER");
    function setUp()public{
        startHoax(OWNER);
        _factory=new Factory(address(0x5FbDB2315678afecb367f032d93F642f64180aa3));
        _vasthavikamainaToken=new VasthavikamainaToken();
        _vasthavikamainaToken.updateFactory(address(_factory),true);
        _factory.setWhiteList(address(_vasthavikamainaToken));
        vm.stopPrank();
    }

    function testcreatePair()public{
        (address _uniPair,LamboToken _lambo)=_factory.createPair("BIF Token","BIF",1e18,address(_vasthavikamainaToken));
    }
}


