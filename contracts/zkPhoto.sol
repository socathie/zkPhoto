// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

/**
 * @title zkPhoto
 * @dev Private authentic photo sharing
 */

interface IVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[65] memory input
    ) external view returns (bool);
}

contract zkPhoto is ERC721 {
    address public verifierAddr;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //on chain data
    mapping(uint256 => uint256[65][16]) data;

    /**
     * @dev Start the game by setting the verifier address
     * @param _verifier address of verifier contract
     */
    constructor(address _verifier) ERC721("zkPhoto 1.0", "ZKP") {
        verifierAddr = _verifier;
    }

    /**
     * @dev call verifyProof in verifier contract
     */
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[65] memory input
    ) private view returns (bool) {
        return IVerifier(verifierAddr).verifyProof(a, b, c, input);
    }

    /**
     * @dev generateTokenURI based on input
     * @param name name in tokenURI
     * @param description description in tokenURI
     * @param image image in tokenURI
     */
    function generateTokenURI(
        string calldata name,
        string calldata description,
        string calldata image
    ) private pure returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            '{',
            '"name": "',
            name,
            '", "description": "',
            description,
            '", "image": "',
            image,
            '"}'
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    /**
     * @dev mint a photo given the proof and the tokenURI
     */
    function mint(
        string calldata name,
        string calldata description,
        string calldata image,
        uint256[2][16] calldata a,
        uint256[2][2][16] calldata b,
        uint256[2][16] calldata c,
        uint256[65][16] calldata input
    ) public returns (uint256) {
        for (uint256 i = 0; i < 16; i++) {
            uint256[2] memory _a = [a[i][0], a[i][1]];
            uint256[2][2] memory _b = [
                [b[i][0][0], b[i][0][1]],
                [b[i][1][0], b[i][1][1]]
            ];
            uint256[2] memory _c = [c[i][0], c[i][1]];
            uint256[65] memory _input;
            for (uint256 j = 0; j < 65; j++) {
                _input[j] = input[i][j];
            }
            require(verifyProof(_a, _b, _c, _input), "Invalid proof");
        }

        _tokenIds.increment();

        uint256 newtokenId = _tokenIds.current();
        _mint(msg.sender, newtokenId);
        _setTokenURI(
            newtokenId,
            generateTokenURI(name, description, image)
        );
        data[newtokenId] = input;
        return newtokenId;
    }

    /**
     * @dev retrieve on chain data by NFT id
     * @param tokenId token id
     */
    function getData(uint256 tokenId)
        public view returns (uint256[65][16] memory)
    {
        require(_exists(tokenId), "Nonexistent token");
        return data[tokenId];
    }
}
