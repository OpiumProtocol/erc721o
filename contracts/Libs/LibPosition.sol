pragma solidity ^0.5.4;

library LibPosition {
  function getLongTokenId(bytes32 _hash) public pure returns (uint256 tokenId) {
    tokenId = uint256(keccak256(abi.encodePacked(_hash, "LONG")));
  }

  function getShortTokenId(bytes32 _hash) public pure returns (uint256 tokenId) {
    tokenId = uint256(keccak256(abi.encodePacked(_hash, "SHORT")));
  }
}
