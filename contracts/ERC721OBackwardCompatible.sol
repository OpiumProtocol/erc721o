pragma solidity ^0.5.4;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol";

import "./ERC721OComposable.sol";
import "./Libs/UintsLib.sol";

contract ERC721OBackwardCompatible is ERC721OComposable {
  using UintsLib for uint256;

  // Interface constants
  bytes4 internal constant INTERFACE_ID_ERC721 = 0x80ac58cd;
  bytes4 internal constant INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
  bytes4 internal constant INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

  // Reciever constants
  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

  // Metadata URI
  string internal baseTokenURI;

  constructor(string memory _baseTokenURI) public ERC721OBase() {
    baseTokenURI = _baseTokenURI;
    _registerInterface(INTERFACE_ID_ERC721);
    _registerInterface(INTERFACE_ID_ERC721_ENUMERABLE);
    _registerInterface(INTERFACE_ID_ERC721_METADATA);
  }

  // ERC721 compatibility
  function implementsERC721() public pure returns (bool) {
    return true;
  }

  /**
    * @dev Gets the owner of a given NFT
    * @param _tokenId uint256 representing the unique token identifier
    * @return address the owner of the token
    */
  function ownerOf(uint256 _tokenId) public view returns (address) {
    if (exists(_tokenId)) {
      return address(this);
    }

    return address(0);
  }

  /**
   *  @dev Gets the number of tokens owned by the address we are checking
   *  @param _owner The adddress we are checking
   *  @return balance The unique amount of tokens owned
   */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    (, uint256[] memory tokens) = tokensOwned(_owner);
    return tokens.length;
  }

  // ERC721 - Enumerable compatibility
  /**
   * @dev Gets the token ID at a given index of all the tokens in this contract
   * Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId) {
    (, uint256[] memory tokens) = tokensOwned(_owner);
    require(_index < tokens.length);
    return tokens[_index];
  }

  // ERC721 - Metadata compatibility
  function tokenURI(uint256 _tokenId) public view returns (string memory tokenUri) {
    require(exists(_tokenId), "Token doesn't exist");
    return string(abi.encodePacked(
      baseTokenURI, 
      _tokenId.uint2str(),
      ".json"
    ));
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    if (exists(_tokenId)) {
      return address(this);
    }

    return address(0);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public nonReentrant {
    _transferFrom(_from, _to, _tokenId, 1);
    require(
      _checkAndCallSafeTransfer(_from, _to, _tokenId, _data),
      "Sent to a contract which is not an ERC721 receiver"
    );
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    _transferFrom(_from, _to, _tokenId, 1);
  }

  /**
   * @dev Internal function to invoke `onERC721Received` on a target address
   * The call is not executed if the target address is not a contract
   * @param _from address representing the previous owner of the given token ID
   * @param _to target address that will receive the tokens
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return whether the call correctly returned the expected magic value
   */
  function _checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  ) internal returns (bool) {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = IERC721Receiver(_to).onERC721Received(
        msg.sender, _from, _tokenId, _data
    );
    return (retval == ERC721_RECEIVED);
  }
}
