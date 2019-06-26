pragma solidity ^0.5.4;

import "openzeppelin-solidity/contracts/introspection/ERC165.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";

import "./Interfaces/IERC721O.sol";
import "./Interfaces/IERC721OReceiver.sol";

import "./Libs/ObjectsLib.sol";

contract ERC721OBase is IERC721O, ERC165, IERC721 {
  // Libraries
  using ObjectLib for ObjectLib.Operations;
  using ObjectLib for uint256;

  // Array with all tokenIds
  uint256[] internal allTokens;

  // Packed balances
  mapping(address => mapping(uint256 => uint256)) internal packedTokenBalance;

  // Operators
  mapping(address => mapping(address => bool)) internal operators;

  // Keeps aprovals for tokens from owner to approved address
  // tokenApprovals[tokenId][owner] = approved
  mapping (uint256 => mapping (address => address)) internal tokenApprovals;

  // Token Id state
  mapping(uint256 => uint256) internal tokenTypes;

  uint256 constant internal INVALID = 0;
  uint256 constant internal POSITION = 1;
  uint256 constant internal PORTFOLIO = 2;

  // Interface constants
  bytes4 internal constant INTERFACE_ID_ERC721O = 0x12345678;

  // 
  mapping (uint256 => bool) private registredPortfolioIds;

  modifier isOperatorOrOwner(address _from) {
    require((msg.sender == _from) || operators[_from][msg.sender], "msg.sender is neither _from nor operator");
    _;
  }

  constructor() public {
    _registerInterface(INTERFACE_ID_ERC721O);
  }

  function implementsERC721O() public pure returns (bool) {
    return true;
  }

  /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existence of
   * @return whether the token exists
   */
  function exists(uint256 _tokenId) public view returns (bool) {
    return tokenTypes[_tokenId] != INVALID;
  }

  /**
   * @dev return the _tokenId type' balance of _address
   * @param _address Address to query balance of
   * @param _tokenId type to query balance of
   * @return Amount of objects of a given type ID
   */
  function balanceOf(address _address, uint256 _tokenId) public view returns (uint256) {
    (uint256 bin, uint256 index) = _tokenId.getTokenBinIndex();
    return packedTokenBalance[_address][bin].getValueInBin(index);
  }

  /**
   * @dev Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
   * @dev Gets Iterate through the list of existing tokens and return the indexes
   *        and balances of the tokens owner by the user
   * @param _owner The adddress we are checking
   * @return indexes The tokenIds
   * @return balances The balances of each token
   */
  function tokensOwned(address _owner) public view returns (uint256[] memory indexes, uint256[] memory balances) {
    uint256 numTokens = totalSupply();
    uint256[] memory tokenIndexes = new uint256[](numTokens);
    uint256[] memory tempTokens = new uint256[](numTokens);

    uint256 count;
    for (uint256 i = 0; i < numTokens; i++) {
      uint256 tokenId = allTokens[i];
      if (balanceOf(_owner, tokenId) > 0) {
        tempTokens[count] = balanceOf(_owner, tokenId);
        tokenIndexes[count] = tokenId;
        count++;
      }
    }

    // copy over the data to a correct size array
    uint256[] memory _ownedTokens = new uint256[](count);
    uint256[] memory _ownedTokensIndexes = new uint256[](count);

    for (uint256 i = 0; i < count; i++) {
      _ownedTokens[i] = tempTokens[i];
      _ownedTokensIndexes[i] = tokenIndexes[i];
    }

    return (_ownedTokensIndexes, _ownedTokens);
  }

  /**
   * @dev Will set _operator operator status to true or false
   * @param _operator Address to changes operator status.
   * @param _approved  _operator's new operator status (true or false)
   */
  function setApprovalForAll(address _operator, bool _approved) public {
    // Update operator status
    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    require(_to != msg.sender, "Can't approve to yourself");
    tokenApprovals[_tokenId][msg.sender] = _to;
    emit Approval(msg.sender, _to, _tokenId);
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 _tokenId, address _tokenOwner) public view returns (address) {
    return tokenApprovals[_tokenId][_tokenOwner];
  }

  /**
   * @dev Function that verifies whether _operator is an authorized operator of _tokenHolder.
   * @param _operator The address of the operator to query status of
   * @param _owner Address of the tokenHolder
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool isOperator) {
    return operators[_owner][_operator];
  }

  function isApprovedOrOwner(
    address _spender,
    address _owner,
    uint256 _tokenId
  ) public view returns (bool) {
    return (
      _spender == _owner ||
      getApproved(_tokenId, _owner) == _spender ||
      isApprovedForAll(_owner, _spender)
    );
  }

  function _updateTokenBalance(
    address _from,
    uint256 _tokenId,
    uint256 _amount,
    ObjectLib.Operations op
  ) internal {
    (uint256 bin, uint256 index) = _tokenId.getTokenBinIndex();
    packedTokenBalance[_from][bin] = packedTokenBalance[_from][bin].updateTokenBalance(
      index, _amount, op
    );
  }
}
