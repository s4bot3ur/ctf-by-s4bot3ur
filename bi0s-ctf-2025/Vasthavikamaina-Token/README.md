# VASTHAVIKAMAINA TOKEN

### Follow the following steps to deploy the chall and run solve script locally

```shell
make deploy
```
- This will deploy all the contracts of the challenge
```shell
make solve
```
- This will run the solve script. 

### Follow the following steps to run the Solve test

```shell
make make create-uniswap-factory
```
This is needed because uniswap contract versions are 0.5.16 and our core contracts version is ^0.8.20. So we can directly import uniswap files into tests. If we do so we will get compiler error.

```shell
make fork-mt TEST=testSolve V=-vv
```
This will run the solve test