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
contract Setup {

    error Setup__Player__Not__Set();
    error Setup__Chall__Not__Solved();
    VasthavikamainaToken public VSTETH;
    IUniswapV2Factory public uniswapV2Factory;
    WhiteListed public whilteListed;
    Factory public factory;
    WETH9 public wETH9;
    Balancer public balancer;
    IUniswapV2Pair public uniPair1;
    IUniswapV2Pair public uniPair2;
    IUniswapV2Pair public uniPair3;
    LamboToken public lamboToken1;
    LamboToken public lamboToken2;
    LamboToken public lamboToken3;
    address public player;
    

    constructor(address _uniswapV2Factory) payable {
        VSTETH=new VasthavikamainaToken();
        uniswapV2Factory=IUniswapV2Factory(_uniswapV2Factory);
        whilteListed=new WhiteListed(_uniswapV2Factory,address(VSTETH));
        factory=new Factory(_uniswapV2Factory);
        VSTETH.addToWhiteList(address(whilteListed));
        VSTETH.updateFactory(address(factory), true);
        factory.setWhiteList(address(VSTETH));
        string memory _name="HattedBull";
        string memory _symbol="HBL";
        (address _uniPair,LamboToken _lamboToken,)=whilteListed.createPair_And_buyQuote{value: 3.3 ether}(factory, _name, _symbol, 20e18, 3.3 ether, 0);
        uniPair1=IUniswapV2Pair(_uniPair);//Pool VETH balance=152534758877722247977 , Pool VETH Debt=20000000000000000000
        lamboToken1=_lamboToken;//diff=132534758877722247977 Hack_Amount=132513467878004258374
        _name="CowrieBO";//Pool VETH balance=25007791505809550535 , Pool VETH Debt=20000000000000000000
        _symbol="CBO";// Hack_Amount=4846141416396402693/1e18 , diff=5007791505809550535s
        (_uniPair,_lamboToken,)=whilteListed.createPair_And_buyQuote{value: 0.05 ether}(factory, _name, _symbol, 20e18, 0.05 ether, 0);
        uniPair2=IUniswapV2Pair(_uniPair);
        lamboToken2=_lamboToken;
        _name="BOVCOIN";//Pool VETH balance=23852171628908871705, Pool VETH Debt=20000000000000000000
        _symbol="BIN";// HAck_Amount=3125543372313501089 , diff=3852171628908871705
        (_uniPair,_lamboToken,)=whilteListed.createPair_And_buyQuote{value: 3 ether}(factory, _name, _symbol, 20e18, 3 ether, 0);
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
    
    function setPlayer(address _player)public{
        player=_player;
    }

    function isSolved()public view returns (bool){
        if(player==address(0)){
            revert Setup__Player__Not__Set();
        }
        if(player.balance< 141.3 ether){
            revert Setup__Chall__Not__Solved();
        }
        return true;
    }
}