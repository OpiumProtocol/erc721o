# ERC721O
[![CircleCI](https://circleci.com/gh/OpiumProtocol/erc721o.svg?style=svg)](https://circleci.com/gh/OpiumProtocol/erc721o)

ERC721O is composable multiclass token standard

# Interface

```
interface ERC721O {
  // ERC721
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  
  function implementsERC721() public pure returns (bool);
  function balanceOf(address owner) public view returns (uint256);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
  function tokenByIndex(uint256 _index) public view returns (uint256);
  function tokenURI(uint256 _tokenId) public view returns (string memory tokenUri);
  function exists(uint256 _tokenId) public view returns (bool);

  function approve(address to, uint256 tokenId) public;
  function getApproved(uint256 tokenId) public view returns (address operator);

  function transferFrom(address from, address to, uint256 tokenId) public;
  function safeTransferFrom(address from, address to, uint256 tokenId) public;
  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

  function setApprovalForAll(address operator, bool _approved) public;
  function isApprovedForAll(address owner, address operator) public view returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

  // ERC721O
  function implementsERC721O() public pure returns (bool);
  function balanceOf(address owner, uint256 tokenId) public view returns (uint256);
  function tokensOwned(address owner) public view returns (uint256[] memory, uint256[] memory);

  function getApproved(uint256 _tokenId, address _tokenOwner) public view returns (address);
  function isApprovedOrOwner(address _spender, address _owner, uint256 _tokenId) public view returns (bool);

  function compose(uint256[] memory _tokenIds, uint256[] memory _tokenRatio, uint256 _quantity) public;
  function decompose(uint256 _portfolioId, uint256[] memory _tokenIds, uint256[] memory _tokenRatio, uint256 _quantity) public;
  function recompose(
    uint256 _portfolioId,
    uint256[] memory _initialTokenIds,
    uint256[] memory _initialTokenRatio,
    uint256[] memory _finalTokenIds,
    uint256[] memory _finalTokenRatio,
    uint256 _quantity
  ) public;

  function transfer(address to, uint256 tokenId, uint256 quantity) public;
  function transferFrom(address from, address to, uint256 tokenId, uint256 quantity) public;
  function safeTransferFrom(address from, address to, uint256 tokenId, uint256 _amount) public;
  function safeTransferFrom(address from, address to, uint256 tokenId, uint256 _amount, bytes memory data) public;
  function batchTransferFrom(address _from, address _to, uint256[] memory _tokenIds, uint256[] memory _amounts) public;
  function safeBatchTransferFrom(address _from, address _to, uint256[] memory tokenIds, uint256[] memory _amounts) public;
  function safeBatchTransferFrom(address _from, address _to, uint256[] memory tokenIds, uint256[] memory _amounts, bytes memory _data) public;

  // Required Events
  event TransferWithQuantity(address indexed from, address indexed to, uint256 indexed tokenId, uint256 quantity);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
  event BatchTransfer(address indexed from, address indexed to, uint256[] tokenTypes, uint256[] amounts);
  event Composition(uint256 portfolioId, uint256[] tokenIds, uint256[] tokenRatio);
}
```

# Install

Install dependencies

```
npm i
```

# Linter

Solidity linter 

```
npm run lint:solidity
```

JS linter

```
npm run lint:js
```

# Tests / Coverage

Tests

```
npm run test
```

Coverage

```
npm run coverage
```

# TODO

- [ ] Clean and refactor comments
- [ ] Tests
- [ ] ERC721O Interface ID

# LICENSES

Our implementation was inspired by [ERC721X](https://github.com/loomnetwork/erc721x)