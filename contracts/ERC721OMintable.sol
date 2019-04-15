pragma solidity ^0.5.4;

import "./ERC721OTransferable.sol";
import "./Libs/LibPosition.sol";

contract ERC721OMintable is ERC721OTransferable {
  // Libraries
  using LibPosition for bytes32;

  // Internal functions
  function _mint(uint256 _tokenId, address _to, uint256 _supply) internal {
    // If the token doesn't exist, add it to the tokens array
    if (!exists(_tokenId)) {
      tokenTypes[_tokenId] = POSITION;
      allTokens.push(_tokenId);
    }

    _updateTokenBalance(_to, _tokenId, _supply, ObjectLib.Operations.ADD);
    emit Transfer(address(this), _to, _tokenId);
    emit TransferWithQuantity(address(this), _to, _tokenId, _supply);
  }

  function _burn(address _tokenOwner, uint256 _tokenId, uint256 _quantity) internal {
    uint256 ownerBalance = balanceOf(_tokenOwner, _tokenId);
    require(ownerBalance >= _quantity, "TOKEN_MINTER:NOT_ENOUGH_POSITIONS");

    _updateTokenBalance(_tokenOwner, _tokenId, _quantity, ObjectLib.Operations.SUB);
    emit Transfer(_tokenOwner, address(this), _tokenId);
    emit TransferWithQuantity(_tokenOwner, address(this), _tokenId, _quantity);
  }

  function _mint(address _buyer, address _seller, bytes32 _derivativeHash, uint256 _quantity) internal {
    _mintLong(_buyer, _derivativeHash, _quantity);
    _mintShort(_seller, _derivativeHash, _quantity);
  }
  
  function _mintLong(address _buyer, bytes32 _derivativeHash, uint256 _quantity) internal {
    uint256 longTokenId = _derivativeHash.getLongTokenId();
    _mint(longTokenId, _buyer, _quantity);
  }
  
  function _mintShort(address _seller, bytes32 _derivativeHash, uint256 _quantity) internal {
    uint256 shortTokenId = _derivativeHash.getShortTokenId();
    _mint(shortTokenId, _seller, _quantity);
  }

  function _registerPortfolio(uint256 _portfolioId, uint256[] memory _tokenIds, uint256[] memory _tokenRatio) internal {
    if (!exists(_portfolioId)) {
      tokenTypes[_portfolioId] = PORTFOLIO;
      emit Composition(_portfolioId, _tokenIds, _tokenRatio);
    }
  }
}
