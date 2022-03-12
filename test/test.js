const { expect } = require("chai");
const { ethers } = require("hardhat");
const fs = require("fs");
const tokenURI = require("./token.json");
const { toHex } = require("web3-utils");
/*
describe("Verifier Contract", function () {
    let Verifier;
    let verifier;

    beforeEach(async function () {
        Verifier = await ethers.getContractFactory("Verifier");
        verifier = await Verifier.deploy();
        await verifier.deployed();
    });

    it("Should return true for correct proofs", async function () {
        for (var i = 0; i < 16; i++) {
            var array = JSON.parse("[" + fs.readFileSync("./circuits/build/zkPhoto/" + i.toString() + "/call.json") + "]");
            expect(await verifier.verifyProof(array[0], array[1], array[2], array[3])).to.be.true;
        }
    });
    it("Should return false for invalid proof", async function () {
        let a = [0, 0];
        let b = [[0, 0], [0, 0]];
        let c = [0, 0];
        let d = Array(65).fill(0);
        expect(await verifier.verifyProof(a, b, c, d)).to.be.false;
    });
});
*/
describe("zkPhoto Contract", function () {
    let zkPhoto;
    let zkphoto;
    let a = [];
    let b = [];
    let c = [];
    let d = [];
    let signers;
    let balance;
    let tx;

    for (var i = 0; i < 16; i++) {
        var array = JSON.parse("[" + fs.readFileSync("./circuits/build/zkPhoto/" + i.toString() + "/call.json") + "]");
        a.push(array[0]);
        b.push(array[1]);
        c.push(array[2]);
        d.push(array[3]);
    };

    beforeEach(async function () {
        let Verifier = await ethers.getContractFactory("Verifier");
        let verifier = await Verifier.deploy();
        await verifier.deployed();
        zkPhoto = await ethers.getContractFactory("zkPhoto");
        zkphoto = await zkPhoto.deploy(verifier.address);
        await zkphoto.deployed();

        signers = await ethers.getSigners();
        balance = await signers[0].getBalance();

        let txn = await zkphoto.mint(tokenURI.name, tokenURI.description, tokenURI.image, a, b, c, d);
        tx = await txn.wait();
    });

    it("mint success", async function () {
        console.log("Cost to mint an NFT: ", balance - await signers[0].getBalance());
        expect(tx.confirmations).to.be.greaterThan(0);
    });

    it("cannot mint an NFT given an invalid proof", async function () {
        let _a = Array(16).fill([0, 0]);
        let _d = Array(16).fill(Array(65).fill(0));
        await zkphoto.mint(tokenURI.name, tokenURI.description, tokenURI.image, _a, b, c, _d)
            .catch((error) => {
                errorString = error.toString();
            });
        expect(errorString).to.have.string("Invalid proof");
    });

    it("cannot mint a image that is already minted", async function () {
        await zkphoto.mint(tokenURI.name, tokenURI.description, tokenURI.image, a, b, c, d)
        .catch((error) => {
            errorString = error.toString();
        });
        expect(errorString).to.have.string("Image already exists");
    });

    it("check minted token uri", async function () {
        var result = await zkphoto.tokenURI(1);
        let json = JSON.parse(Buffer.from(result.split(",")[1], "base64").toString("ascii"));
        expect(json.name).to.equal(tokenURI.name);
        expect(json.description).to.equal(tokenURI.description);
        expect(json.image).to.equal(tokenURI.image);
        expect(json.external_url).to.equal("https://zkPhoto.one");
    });

    it("extract the low res image from the contract URI given an id", async function () {
        let data = await zkphoto.getData(1);
        for (var i = 0; i < data.length; i++) {
            for (var j = 0; j < data[0].length; j++) {
                expect(BigInt(data[i][j])).to.equal(BigInt(d[i][j]));
            }
        }
    });
});