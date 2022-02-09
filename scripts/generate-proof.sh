#!/bin/bash

cd circuits
mkdir -p build

for k in {0..15}; do
    echo "Slice ${k}"
    mkdir -p build/zkPhoto/
    mkdir -p build/zkPhoto/${k}

    # generate witness
    node "build/zkPhoto_js/generate_witness.js" build/zkPhoto_js/zkPhoto.wasm ../image/slice${k}.json build/zkPhoto/${k}/witness.wtns
        
    # generate proof
    snarkjs groth16 prove build/zkPhoto/circuit_final.zkey build/zkPhoto/${k}/witness.wtns build/zkPhoto/${k}/proof.json build/zkPhoto/${k}/public.json

    # verify proof
    snarkjs groth16 verify build/zkPhoto/verification_key.json build/zkPhoto/${k}/public.json build/zkPhoto/${k}/proof.json

    # generate call
    snarkjs zkey export soliditycalldata build/zkPhoto/${k}/public.json build/zkPhoto/${k}/proof.json > build/zkPhoto/${k}/call.json
done 
