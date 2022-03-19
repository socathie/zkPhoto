# zkPhoto

This project demonstrates a small stepping stone toward #2 of [Brian Gu’s Six ZK Moonshots](https://www.youtube.com/watch?v=c-nQx8peyKU). The idea is to have an on-chain data marketplace where users can trade private data, for example, “a high-res image that downsamples to a known low-res image”, using ZK. Within the scope of this proposal, the MVP is to implement a dApp that (0) use ZK to prove that the low-res image is downsized from an actual high-res image, (1) mint an NFT that contains the downsized image, *as well as the hash of the original image, (2) implement an in-browser camera for authentic on-chain photo-taking, and more. This repo will cover Phase 0 and Phase 1.

The contract has already been deployed on Harmony testnet and the first NFT has been minted.

[ERC721 contract on testnet](https://explorer.pops.one/address/0x0346849160a9b74887c29ae946f73a8bf7ae2588)

For more details on the development and demo videos, click [here](https://open.harmony.one/funding/1000-contributors-78m/cathie-so/zkphoto-private-authentic-photo-sharing).

Run `npm i` to install. 

To compile the circuits, generate proofs, and test the contracts using the sample `image/input.png` locally, run

```shell
npm run test:fullProof
```

To deploy on Harmony testnet, run the above command first, then change the private key in `hardhat.config.js` to your own private key. The contracts have also been deployed to the addresses to `deployed.txt` and can be accessed directly.

```shell
npx hardhat deploy --network testnet
```

You can try minting the sample image by running:

```shell
npx hardhat run scripts/mint-sample.js --network testnet
```