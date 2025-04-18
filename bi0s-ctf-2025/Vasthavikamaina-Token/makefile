export ANVIL_RPC_URL=http://127.0.0.1:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

build-core:
	export FOUNDRY_PROFILE=core && forge build

build-uniswap:
	export FOUNDRY_PROFILE=uniswap && forge build

anvil:
	anvil --code-size-limit 30000 --gas-limit 35000000 --accounts 1 --balance 33000 --block-time 3

mt:
	forge test --mt "$(TEST)" "$(V)"

fork-mt:
	forge test --mt "$(TEST)" --fork-url $(ANVIL_RPC_URL) "$(V)"


build:
	forge build

deploy: chall-conditions

chall-conditions: create-contracts
	forge script script/core/ChallConditions.s.sol:ChallConditions --rpc-url $(ANVIL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --gas-estimate-multiplier 140 "$(V)"


create-contracts: create-uniswap-factory
	forge script script/core/Deploy.s.sol:Deploy --rpc-url $(ANVIL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast "$(V)"

create-uniswap-factory:
	rm -rf broadcast/* && forge create src/uniswap-v2/UniswapV2Factory.sol:UniswapV2Factory \
		--rpc-url $(ANVIL_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--constructor-args 0000000000000000000000000000000000000000 


solve:
	rm -rf broadcast/Solve.s.sol/* &&\
	for i in 1 2 3; do \
		echo "Hack $$i..."; \
		$(MAKE) solve-script; \
		sleep 3; \
	done

solve-script:
	forge script script/Solve.s.sol:Solve --rpc-url $(ANVIL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast "$(V)"
