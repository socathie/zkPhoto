const { base64 } = require("ethers/lib/utils");
const { encodePacked } = require("web3-utils");

let abi = encodePacked(
    '{',
    '"description": "',
    'pouring latte art',
    '", "name": "',
    'hong kong add oil',
    '"}'
    )

let json = base64.encode(encodePacked(
    'data:application/json;base64,',
    base64.encode(abi)
))


console.log(base64.decode(json));