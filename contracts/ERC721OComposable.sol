pragma solidity ^0.5.4;

import "./Libs/UintArray.sol";

import "./ERC721OMintable.sol";

contract ERC721OComposable is ERC721OMintable {
  // Libraries
  using UintArray for uint256[];

  function compose(uint256[] memory _tokenIds, uint256[] memory _tokenRatio, uint256 _quantity) public {
    require(_tokenIds.length == _tokenRatio.length, "TOKEN_MINTER:TOKEN_IDS_AND_RATIO_LENGTH_DOES_NOT_MATCH");
    require(_quantity > 0, "TOKEN_MINTER:WRONG_QUANTITY");
    require(_tokenIds.length > 0, "TOKEN_MINTER:WRONG_QUANTITY");
    require(_tokenIds.isUnique(), "TOKEN_MINTER:TOKEN_IDS_NOT_UNIQUE");

    for (uint256 i = 0; i < _tokenIds.length; i++) {
      _burn(msg.sender, _tokenIds[i], _tokenRatio[i] * _quantity);
    }

    uint256 portfolioId = uint256(keccak256(abi.encodePacked(
      _tokenIds,
      _tokenRatio
    )));

    _registerPortfolio(portfolioId, _tokenIds, _tokenRatio);
    _mint(portfolioId, msg.sender, _quantity);
  }

  function decompose(uint256 _portfolioId, uint256[] memory _tokenIds, uint256[] memory _tokenRatio, uint256 _quantity) public {
    require(_tokenIds.length == _tokenRatio.length, "TOKEN_MINTER:TOKEN_IDS_AND_RATIO_LENGTH_DOES_NOT_MATCH");
    require(_quantity > 0, "TOKEN_MINTER:WRONG_QUANTITY");
    require(_tokenIds.length > 0, "TOKEN_MINTER:WRONG_QUANTITY");
    require(_tokenIds.isUnique(), "TOKEN_MINTER:TOKEN_IDS_NOT_UNIQUE");

    uint256 portfolioId = uint256(keccak256(abi.encodePacked(
      _tokenIds,
      _tokenRatio
    )));

    require(portfolioId == _portfolioId, "TOKEN_MINTER:WRONG_PORTFOLIO_ID");
    _burn(msg.sender, _portfolioId, _quantity);

    for (uint256 i = 0; i < _tokenIds.length; i++) {
      _mint(_tokenIds[i], msg.sender, _tokenRatio[i] * _quantity);
    }
  }

  function recompose(
    uint256 _portfolioId,
    uint256[] memory _initialTokenIds,
    uint256[] memory _initialTokenRatio,
    uint256[] memory _finalTokenIds,
    uint256[] memory _finalTokenRatio,
    uint256 _quantity
  ) public {
    require(_initialTokenIds.length == _initialTokenRatio.length, "TOKEN_MINTER:INITIAL_TOKEN_IDS_AND_RATIO_LENGTH_DOES_NOT_MATCH");
    require(_finalTokenIds.length == _finalTokenRatio.length, "TOKEN_MINTER:FINAL_TOKEN_IDS_AND_RATIO_LENGTH_DOES_NOT_MATCH");
    require(_quantity > 0, "TOKEN_MINTER:WRONG_QUANTITY");
    require(_initialTokenIds.length > 0, "TOKEN_MINTER:WRONG_QUANTITY");
    require(_finalTokenIds.length > 0, "TOKEN_MINTER:WRONG_QUANTITY");
    require(_initialTokenIds.isUnique(), "TOKEN_MINTER:TOKEN_IDS_NOT_UNIQUE");
    require(_finalTokenIds.isUnique(), "TOKEN_MINTER:TOKEN_IDS_NOT_UNIQUE");

    uint256 oldPortfolioId = uint256(keccak256(abi.encodePacked(
      _initialTokenIds,
      _initialTokenRatio
    )));

    require(oldPortfolioId == _portfolioId, "TOKEN_MINTER:WRONG_PORTFOLIO_ID");
    _burn(msg.sender, _portfolioId, _quantity);
    
    _removedIds(_initialTokenIds, _initialTokenRatio, _finalTokenIds, _finalTokenRatio, _quantity);
    _addedIds(_initialTokenIds, _initialTokenRatio, _finalTokenIds, _finalTokenRatio, _quantity);
    _keptIds(_initialTokenIds, _initialTokenRatio, _finalTokenIds, _finalTokenRatio, _quantity);

    uint256 newPortfolioId = uint256(keccak256(abi.encodePacked(
      _finalTokenIds,
      _finalTokenRatio
    )));

    _registerPortfolio(newPortfolioId, _finalTokenIds, _finalTokenRatio);
    _mint(newPortfolioId, msg.sender, _quantity);
  }

  function _removedIds(
    uint256[] memory _initialTokenIds,
    uint256[] memory _initialTokenRatio,
    uint256[] memory _finalTokenIds,
    uint256[] memory _finalTokenRatio,
    uint256 _quantity
  ) private {
    (uint256[] memory removedIds, uint256[] memory removedIdsIdxs) = _initialTokenIds.difference(_finalTokenIds);

    for (uint256 i = 0; i < removedIds.length; i++) {
      uint256 index = removedIdsIdxs[i];
      _mint(_initialTokenIds[index], msg.sender, _initialTokenRatio[index] * _quantity);
    }
  }

  function _addedIds(
      uint256[] memory _initialTokenIds,
      uint256[] memory _initialTokenRatio,
      uint256[] memory _finalTokenIds,
      uint256[] memory _finalTokenRatio,
      uint256 _quantity
  ) private {
    (uint256[] memory addedIds, uint256[] memory addedIdsIdxs) = _finalTokenIds.difference(_initialTokenIds);

    for (uint256 i = 0; i < addedIds.length; i++) {
      uint256 index = addedIdsIdxs[i];
      _burn(msg.sender, _finalTokenIds[index], _finalTokenRatio[index] * _quantity);
    }
  }

  function _keptIds(
      uint256[] memory _initialTokenIds,
      uint256[] memory _initialTokenRatio,
      uint256[] memory _finalTokenIds,
      uint256[] memory _finalTokenRatio,
      uint256 _quantity
  ) private {
    (uint256[] memory keptIds, uint256[] memory keptInitialIdxs, uint256[] memory keptFinalIdxs) = _initialTokenIds.intersect(_finalTokenIds);

    for (uint256 i = 0; i < keptIds.length; i++) {
      uint256 initialIndex = keptInitialIdxs[i];
      uint256 finalIndex = keptFinalIdxs[i];

      if (_initialTokenRatio[initialIndex] > _finalTokenRatio[finalIndex]) {
        uint256 diff = _initialTokenRatio[initialIndex] - _finalTokenRatio[finalIndex];
        _mint(_initialTokenIds[initialIndex], msg.sender, diff * _quantity);
      } else if (_initialTokenRatio[initialIndex] < _finalTokenRatio[finalIndex]) {
        uint256 diff = _finalTokenRatio[finalIndex] - _initialTokenRatio[initialIndex];
        _burn(msg.sender, _initialTokenIds[initialIndex], diff * _quantity);
      }
    }
  }
}
