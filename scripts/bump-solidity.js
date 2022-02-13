const fs = require("fs");
const solidityRegex = /pragma solidity \^\d+\.\d+\.\d+/

process.chdir('./contracts');
const content = fs.readFileSync("verifier.sol", { encoding: 'utf-8' });
const bumped = content.replace(solidityRegex, 'pragma solidity ^0.8.4')

fs.writeFileSync("verifier.sol", bumped);

