#!/bin/bash

#export NODE_OPTIONS="--max-old-space-size=16384"

cd circuits
mkdir -p build

if [ -f ./powersOfTau28_hez_final_14.ptau ]; then
    echo "powersOfTau28_hez_final_14.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_14.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_14.ptau
fi

echo "Compiling: zkPhoto..."

mkdir -p build/zkPhoto

# compile circuit

if [ -f ./build/zkPhoto.r1cs ]; then
    echo "Circuit already compiled. Skipping."
else
    circom zkPhoto.circom --r1cs --wasm --sym -o build
    snarkjs r1cs info build/zkPhoto.r1cs
fi

# Start a new zkey and make a contribution

if [ -f ./build/zkPhoto/verification_key.json ]; then
    echo "verification_key.json already exists. Skipping."
else
    snarkjs groth16 setup build/zkPhoto.r1cs powersOfTau28_hez_final_14.ptau build/zkPhoto/circuit_0000.zkey
    snarkjs zkey contribute build/zkPhoto/circuit_0000.zkey build/zkPhoto/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
    snarkjs zkey export verificationkey build/zkPhoto/circuit_final.zkey build/zkPhoto/verification_key.json
fi

# generate solidity contract
snarkjs zkey export solidityverifier build/zkPhoto/circuit_final.zkey ../contracts/verifier.sol