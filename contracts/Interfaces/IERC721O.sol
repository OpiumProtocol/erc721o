pragma solidity ^0.5.4;

contract IERC721O {
  // Token description
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function totalSupply() public view returns (uint256);
  function exists(uint256 _tokenId) public view returns (bool);

  function implementsERC721() public pure returns (bool);
  function tokenByIndex(uint256 _index) public view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
  function tokenURI(uint256 _tokenId) public view returns (string memory tokenUri);
  function getApproved(uint256 _tokenId) public view returns (address);
  
  function implementsERC721O() public pure returns (bool);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function balanceOf(address owner) public view returns (uint256);
  function balanceOf(address _owner, uint256 _tokenId) public view returns (uint256);
  function tokensOwned(address _owner) public view returns (uint256[] memory, uint256[] memory);

  // Non-Fungible Safe Transfer From
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public;

  // Non-Fungible Unsafe Transfer From
  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  // Fungible Unsafe Transfer
  function transfer(address _to, uint256 _tokenId, uint256 _quantity) public;

  // Fungible Unstafe Transfer From
  function transferFrom(address _from, address _to, uint256 _tokenId, uint256 _quantity) public;

  // Fungible Safe Transfer From
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, uint256 _amount) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, uint256 _amount, bytes memory _data) public;

  // Fungible Safe Batch Transfer From
  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _tokenIds, uint256[] memory _amounts) public;
  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _tokenIds, uint256[] memory _amounts, bytes memory _data) public;

  // Fungible Unsafe Batch Transfer From
  function batchTransferFrom(address _from, address _to, uint256[] memory _tokenIds, uint256[] memory _amounts) public;

  // Aprovals
  function setApprovalForAll(address _operator, bool _approved) public;
  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId, address _tokenOwner) public view returns (address);
  function isApprovedForAll(address _owner, address _operator) public view returns (bool isOperator);
  function isApprovedOrOwner(address _spender, address _owner, uint256 _tokenId) public view returns (bool);
  function permit(address _holder, address _spender, uint256 _nonce, uint256 _expiry, bool _allowed, bytes calldata _signature) external;

  // Composable
  function compose(uint256[] memory _tokenIds, uint256[] memory _tokenRatio, uint256 _quantity) public;
  function decompose(uint256 _portfolioId, uint256[] memory _tokenIds, uint256[] memory _tokenRatio, uint256 _quantity) public;
  function recompose(uint256 _portfolioId, uint256[] memory _initialTokenIds, uint256[] memory _initialTokenRatio, uint256[] memory _finalTokenIds, uint256[] memory _finalTokenRatio, uint256 _quantity) public;

  // Required Events
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event TransferWithQuantity(address indexed from, address indexed to, uint256 indexed tokenId, uint256 quantity);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
  event BatchTransfer(address indexed from, address indexed to, uint256[] tokenTypes, uint256[] amounts);
  event Composition(uint256 portfolioId, uint256[] tokenIds, uint256[] tokenRatio);
}
