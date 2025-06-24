use rayon::prelude::*;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use tiny_keccak::{Hasher, Keccak};
use rand::Rng;
use hex::encode;
use hex_literal::hex;
use std::fs::OpenOptions;
use std::io::Write;

const TARGET_PREFIX: &[u8] = &[0x00,0x00,0x00,0x00]; 
const DEPLOYER: [u8; 20] = hex!("Dc64a140Aa3E981100a9becA4E685f962f0cF6C9");

fn keccak256(input: &[u8]) -> [u8; 32] {
    let mut output = [0u8; 32];
    let mut hasher = Keccak::v256();
    hasher.update(input);
    hasher.finalize(&mut output);
    output
}

fn create2_address(salt: &[u8; 32], deployer: &[u8; 20], init_code_hash: &[u8; 32]) -> [u8; 20] {
    let mut data = Vec::with_capacity(1 + 20 + 32 + 32);
    data.push(0xff);
    data.extend_from_slice(deployer);
    data.extend_from_slice(salt);
    data.extend_from_slice(init_code_hash);
    let hash = keccak256(&data);
    hash[12..32].try_into().unwrap()
}

fn main() {
    let init_code_hash: [u8; 32] = hex!("c7106b83393dde32127292c8aa245a425563699b1a8ab3ce78f2f2c93e30fb3b");
    let found = Arc::new(AtomicBool::new(false));
    loop {
        if found.load(Ordering::Relaxed) {
            break;
        }
        (0..100_000u64).into_par_iter().for_each_with(found.clone(), |found, _| {
            if found.load(Ordering::Relaxed) {
                return;
            }

            let salt: [u8; 32] = rand::thread_rng().gen();
            let addr = create2_address(&salt, &DEPLOYER, &init_code_hash);

            if addr.starts_with(TARGET_PREFIX) {
                if !found.swap(true, Ordering::SeqCst) {

                    let mut file = OpenOptions::new()
                        .create(true)
                        .write(true)
                        .truncate(true)
                        .open(".env")
                        .expect("Failed to create .env file");
                    writeln!(file, "SALT=0x{}", encode(salt)).expect("Failed to write to file");
                    std::process::exit(0);
                }
            }
        });
    }
}
