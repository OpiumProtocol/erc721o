pragma solidity ^0.5.4;

/**
 * @title ERC721O token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 *  from ERC721O contracts.
 */
contract IERC721OReceiver {
  /**
    * @dev Magic value to be returned upon successful reception of an amount of ERC721O tokens
    *  ERC721O_RECEIVED = `bytes4(keccak256("onERC721OReceived(address,address,uint256,uint256,bytes)"))` = 0xf891ffe0
    *  ERC721O_BATCH_RECEIVED = `bytes4(keccak256("onERC721OBatchReceived(address,address,uint256[],uint256[],bytes)"))` = 0xd0e17c0b
    */
  bytes4 constant internal ERC721O_RECEIVED = 0xf891ffe0;
  bytes4 constant internal ERC721O_BATCH_RECEIVED = 0xd0e17c0b;

  function onERC721OReceived(
    address _operator,
    address _from,
    uint256 tokenId,
    uint256 amount,
    bytes memory data
  ) public returns(bytes4);

  function onERC721OBatchReceived(
    address _operator,
    address _from,
    uint256[] memory _types,
    uint256[] memory _amounts,
    bytes memory _data
  ) public returns (bytes4);
}
