pragma solidity ^0.5.4;

import "./ERC721OBackwardCompatible.sol";

contract TokenMinter is ERC721OBackwardCompatible {
  constructor(string memory _baseTokenURI) public ERC721OBackwardCompatible(_baseTokenURI) {}

  function mint(uint256 _tokenId, address _to, uint256 _supply) external {
    _mint(_tokenId, _to, _supply);
  }

  function name() external view returns (string memory) {
    return "Opium Protocol Position Token";
  }

  function symbol() external view returns (string memory) {
    return "OPIUM";
  }
}
