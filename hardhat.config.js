require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require('hardhat-deploy');
require('hardhat-contract-sizer');

// Replace this private key with your Harmony account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const HARMONY_PRIVATE_KEY_1 = "insert private key here";
const HARMONY_PRIVATE_KEY_2 = "insert private key here";

module.exports = {
  solidity: {
    version: "0.8.4",
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    testnet: {
      url: `https://api.s0.b.hmny.io`,
      accounts: [`${HARMONY_PRIVATE_KEY_1}`, `${HARMONY_PRIVATE_KEY_2}`],
      allowUnlimitedContractSize: true,
    },
    mainnet: {
      url: `https://api.harmony.one`,
      accounts: [`${HARMONY_PRIVATE_KEY_1}`, `${HARMONY_PRIVATE_KEY_2}`],
      allowUnlimitedContractSize: true,
    },
  },
  namedAccounts: {
    deployer: 0,
  },
  paths: {
    deploy: 'deploy',
    deployments: 'deployments',
  },
  mocha: {
    timeout: 100000
  }
};
