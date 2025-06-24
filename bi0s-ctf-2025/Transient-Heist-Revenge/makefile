export ANVIL_RPC_URL=http://127.0.0.1:8545
export ANVIL_PK=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

anvil:
	anvil -a 1 --balance 451078305590476001
	
deploy: create-contracts

create-contracts: create-bi0sSwap-factory
	forge script script/Deploy.s.sol:Deploy --rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_PK) --broadcast "$(V)" --contracts src/core/ --use 0.8.24

create-bi0sSwap-factory:
	rm -rf broadcast/* && forge create src/bi0s-swap-v1/Bi0sSwapFactory.sol:Bi0sSwapFactory \
		--rpc-url $(ANVIL_RPC_URL) \
		--private-key $(ANVIL_PK) \
		--broadcast \
		--constructor-args 0000000000000000000000000000000000000000 

solve:
	forge script script/Solve.s.sol:Solve --rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_PK) --broadcast "$(V)" 


author-solve:create-vanity
	forge script script/Author/Solve.s.sol:Solve --rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_PK) --broadcast "$(V)" 

create-vanity:
	cargo run --manifest-path script/Author/Vanity-Generator/Cargo.toml --release


