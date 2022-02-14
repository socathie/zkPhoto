// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title zkPhoto
 * @dev Private authentic photo sharing
 */

interface IVerifier {
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[65] memory input
        ) external view returns (bool);
}

contract zkPhoto is ERC721 {

    address public verifierAddr;

    /**
    * @dev Start the game by setting the verifier address
    * @param _verifier address of verifier contract
    */
    constructor(address _verifier) ERC721("Item", "ITM") {
       verifierAddr = _verifier;
    }

    /**
    * @dev call verifyProof in verifier contract
    */
    function verifyProof (
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[65] memory input
        ) private view returns (bool) {
        return IVerifier(verifierAddr).verifyProof(a, b, c, input);
    }
}