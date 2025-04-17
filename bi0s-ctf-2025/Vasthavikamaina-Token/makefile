export ANVIL_RPC_URL=http://127.0.0.1:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

build-core:
	export FOUNDRY_PROFILE=core && forge build

build-uniswap:
	export FOUNDRY_PROFILE=uniswap && forge build

create-uniswap-factory:
	forge create src/uniswap-v2/UniswapV2Factory.sol:UniswapV2Factory \
		--rpc-url $(ANVIL_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--constructor-args 0000000000000000000000000000000000000000

anvil:
	anvil

mt:
	forge test --mt "$(TEST)" 

fork-mt:
	forge test --mt "$(TEST)" --fork-url $(ANVIL_RPC_URL) "$(v)"
