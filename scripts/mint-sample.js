const { ethers } = require("hardhat");
const address = require("./address.json");
const zkPhotoArtifact = require("../artifacts/contracts/zkPhoto.sol/zkPhoto.json");
const tokenURI = require('../test/token.json');
const fs = require('fs');

let zkPhoto;

async function connectZkPhoto() {
    let signers = await ethers.getSigners();

    zkPhoto = new ethers.Contract(address['zkPhoto'], zkPhotoArtifact.abi, signers[0]);

    //console.log("Connect to zkPhoto Contract:", zkPhoto.callStatic);
}

async function mint() {

    await connectZkPhoto();
    
    let a = [];
    let b = [];
    let c = [];
    let d = [];

    for (var i = 0; i < 16; i++) {
        var array = JSON.parse("[" + fs.readFileSync('./circuits/build/zkPhoto/' + i.toString() + '/call.json') + "]");
        a.push(array[0]);
        b.push(array[1]);
        c.push(array[2]);
        d.push(array[3]);
    };

    let txn = await zkPhoto.mint(tokenURI.name, tokenURI.description, tokenURI.image, a, b, c, d);
    let tx = await txn.wait();
    console.log(tx)
}

mint();