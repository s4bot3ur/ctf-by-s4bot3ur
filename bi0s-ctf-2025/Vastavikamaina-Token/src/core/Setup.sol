//SPDX-Identifier-License: BUSL-1.1
pragma solidity ^0.8.20;

import {VasthavikamainaToken} from "./VasthavikamainaToken.sol";
import {IUniswapV2Factory} from "../uniswap-v2/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "../uniswap-v2/interfaces/IUniswapV2Pair.sol";
import {WhiteListed} from "./WhiteListed.sol";
import {Factory} from "./Factory.sol";
import {LamboToken} from "./LamboToken.sol";
import {WETH9} from "./WETH.sol";
import {Balancer} from "./Balancer.sol";

/*
 * @title:Vastavikamaina Token
 * @author:s4bot3ur
 */
contract Setup {

    error Setup__Chall__Not__Solved();
    VasthavikamainaToken public VSTETH;
    IUniswapV2Factory public uniswapV2Factory;
    WhiteListed public whiteListed;
    Factory public factory;
    WETH9 public wETH9;
    Balancer public balancer;
    IUniswapV2Pair public uniPair1;
    IUniswapV2Pair public uniPair2;
    IUniswapV2Pair public uniPair3;
    LamboToken public lamboToken1;
    LamboToken public lamboToken2;
    LamboToken public lamboToken3;
    bool public solved;
    

    constructor(address _uniswapV2Factory) payable {
        VSTETH=new VasthavikamainaToken();
        uniswapV2Factory=IUniswapV2Factory(_uniswapV2Factory);
        whiteListed=new WhiteListed(_uniswapV2Factory,address(VSTETH));
        factory=new Factory(_uniswapV2Factory);
        VSTETH.addToWhiteList(address(whiteListed));
        VSTETH.updateFactory(address(factory), true);
        factory.setWhiteList(address(VSTETH));
        string memory _name="HattedBull";
        string memory _symbol="HBL";
        (address _uniPair,LamboToken _lamboToken,)=whiteListed.createPair_And_buyQuote{value: 3.3 ether}(factory, _name, _symbol, 20e18, 3.3 ether, 0);
        uniPair1=IUniswapV2Pair(_uniPair);
        lamboToken1=_lamboToken;
        _name="CowrieBO";
        _symbol="CBO";
        (_uniPair,_lamboToken,)=whiteListed.createPair_And_buyQuote{value: 0.05 ether}(factory, _name, _symbol, 20e18, 0.05 ether, 0);
        uniPair2=IUniswapV2Pair(_uniPair);
        lamboToken2=_lamboToken;
        _name="BOVCOIN";
        (_uniPair,_lamboToken,)=whiteListed.createPair_And_buyQuote{value: 3 ether}(factory, _name, _symbol, 20e18, 3 ether, 0);
        uniPair3=IUniswapV2Pair(_uniPair);
        lamboToken3=_lamboToken;
        wETH9=new WETH9();
        balancer=new Balancer();
        balancer.approveToken(address(address(lamboToken1)));
        balancer.approveToken(address(address(lamboToken2)));
        balancer.approveToken(address(address(lamboToken3)));
        balancer.approveToken(address(wETH9));
        balancer.approveToken(address(VSTETH));
    }

    function solve()public{
        if(msg.sender.balance< 141.3 ether){
            revert Setup__Chall__Not__Solved();
        }
        solved=true;
    }
    

    function isSolved()public view returns (bool){
        if(!solved){
            return false;
        }
        return true;
    }
}