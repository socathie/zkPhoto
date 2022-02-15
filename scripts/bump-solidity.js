const fs = require("fs");
const solidityRegex = /pragma solidity \^\d+\.\d+\.\d+/

let content = fs.readFileSync("./contracts/verifier.sol", { encoding: 'utf-8' });
let bumped = content.replace(solidityRegex, 'pragma solidity ^0.8.4');

fs.writeFileSync("./contracts/verifier.sol", bumped);

const contracts = [
    './node_modules/@openzeppelin/contracts/utils/Counters.sol',
    './node_modules/@openzeppelin/contracts/utils/Strings.sol',
    './node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol',
    './node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol',
    './node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol',
    './node_modules/@openzeppelin/contracts/utils/Address.sol',
    './node_modules/@openzeppelin/contracts/math/SafeMath.sol',
    './node_modules/@openzeppelin/contracts/introspection/ERC165.sol',
    './node_modules/@openzeppelin/contracts/introspection/IERC165.sol',
    './node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol',
    './node_modules/@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol',
    './node_modules/@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol',
    './node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol',
    './node_modules/@openzeppelin/contracts/utils/Context.sol'
]

const openzeppelinRegex = /pragma solidity >=\d+\.\d+\.\d+ <\d+\.\d+\.\d+/

for (var i = 0; i < contracts.length; i++) {
    content = fs.readFileSync(contracts[i], { encoding: 'utf-8' });
    bumped = content.replace(openzeppelinRegex, 'pragma solidity ^0.8.4');

    fs.writeFileSync(contracts[i], bumped);
}

const payableRegex = "return msg.sender"

content = fs.readFileSync('./node_modules/@openzeppelin/contracts/utils/Context.sol', { encoding: 'utf-8' });
bumped = content.replace(payableRegex, 'return payable(msg.sender)');

fs.writeFileSync('./node_modules/@openzeppelin/contracts/utils/Context.sol', bumped);
