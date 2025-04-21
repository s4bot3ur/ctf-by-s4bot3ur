export ANVIL_RPC_URL=http://127.0.0.1:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

deploy:
	rm -rf ./broadcast/* &&\
	forge script script/Deploy/DeploySetup.s.sol:DeploySetup --rpc-url $(ANVIL_RPC_URL)  --private-key $(PRIVATE_KEY) --broadcast

solve:
	forge script script/solve.s.sol:solve --rpc-url $(ANVIL_RPC_URL)  --private-key $(PRIVATE_KEY) --broadcast

anvil:
	anvil -a 1 --balance 1

solve-test:
	forge test --mt test_Exploit -vv