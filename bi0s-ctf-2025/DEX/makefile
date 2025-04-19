export ANVIL_RPC_URL=http://127.0.0.1:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

anvil:
	anvil --balance 1000000 --block-time 10

deploy:
	rm -rf ./broadcast/* && forge script script/deploy/DeploySetup.s.sol:DeploySetup --rpc-url $(ANVIL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

solve:
	for i in 1 2 3; do \
		sleep 60 && \
		make solve-script && \
		sleep 10 && \
		make solve-script ; \
	done && \
	rm -rf ./broadcast/*

solve-script:
	forge script script/Solve.s.sol:Solve --rpc-url $(ANVIL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

solve-test:
	forge test --mt test_Solving_Chall -vv