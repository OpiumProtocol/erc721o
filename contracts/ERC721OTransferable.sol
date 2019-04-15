pragma solidity ^0.5.4;

import "../node_modules/openzeppelin-solidity/contracts/utils/Address.sol";
import "../node_modules/openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";

import "./ERC721OBase.sol";

contract ERC721OTransferable is ERC721OBase, ReentrancyGuard {
  // Libraries
  using Address for address;

  // safeTransfer constants
  bytes4 internal constant ERC721O_RECEIVED = 0xf891ffe0;
  bytes4 internal constant ERC721O_BATCH_RECEIVED = 0xd0e17c0b;

  function batchTransferFrom(address _from, address _to, uint256[] memory _tokenIds, uint256[] memory _amounts) public {
    // Batch Transfering
    _batchTransferFrom(_from, _to, _tokenIds, _amounts);
  }

  /**
    * @dev transfer objects from different tokenIds to specified address
    * @param _from The address to BatchTransfer objects from.
    * @param _to The address to batchTransfer objects to.
    * @param _tokenIds Array of tokenIds to update balance of
    * @param _amounts Array of amount of object per type to be transferred.
    * @param _data Data to pass to onERC721OReceived() function if recipient is contract
    * Note:  Arrays should be sorted so that all tokenIds in a same bin are adjacent (more efficient).
    */
  function safeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] memory _tokenIds,
    uint256[] memory _amounts,
    bytes memory _data
  ) public nonReentrant {
    // Batch Transfering
    _batchTransferFrom(_from, _to, _tokenIds, _amounts);

    // Pass data if recipient is contract
    if (_to.isContract()) {
      bytes4 retval = IERC721OReceiver(_to).onERC721OBatchReceived(
        msg.sender, _from, _tokenIds, _amounts, _data
      );
      require(retval == ERC721O_BATCH_RECEIVED);
    }
  }

  function safeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] memory _tokenIds,
    uint256[] memory _amounts
  ) public {
    safeBatchTransferFrom(_from, _to, _tokenIds, _amounts, "");
  }

  function transfer(address _to, uint256 _tokenId, uint256 _amount) public {
    _transferFrom(msg.sender, _to, _tokenId, _amount);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId, uint256 _amount) public {
    _transferFrom(_from, _to, _tokenId, _amount);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId, uint256 _amount) public {
    safeTransferFrom(_from, _to, _tokenId, _amount, "");
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId, uint256 _amount, bytes memory _data) public nonReentrant {
    _transferFrom(_from, _to, _tokenId, _amount);
    require(
      _checkAndCallSafeTransfer(_from, _to, _tokenId, _amount, _data),
      "Sent to a contract which is not an ERC721O receiver"
    );
  }

  /**
    * @dev transfer objects from different tokenIds to specified address
    * @param _from The address to BatchTransfer objects from.
    * @param _to The address to batchTransfer objects to.
    * @param _tokenIds Array of tokenIds to update balance of
    * @param _amounts Array of amount of object per type to be transferred.
    * Note:  Arrays should be sorted so that all tokenIds in a same bin are adjacent (more efficient).
    */
  function _batchTransferFrom(
    address _from,
    address _to,
    uint256[] memory _tokenIds,
    uint256[] memory _amounts
  ) internal isOperatorOrOwner(_from) {
    // Requirements
    require(_tokenIds.length == _amounts.length, "Inconsistent array length between args");
    require(_to != address(0), "Invalid recipient");

    // Load first bin and index where the object balance exists
    (uint256 bin, uint256 index) = ObjectLib.getTokenBinIndex(_tokenIds[0]);

    // Balance for current bin in memory (initialized with first transfer)
    // Written with bad library syntax instead of as below to bypass stack limit error
    uint256 balFrom = ObjectLib.updateTokenBalance(
      packedTokenBalance[_from][bin], index, _amounts[0], ObjectLib.Operations.SUB
    );
    uint256 balTo = ObjectLib.updateTokenBalance(
      packedTokenBalance[_to][bin], index, _amounts[0], ObjectLib.Operations.ADD
    );

    emit Transfer(_from, _to, _tokenIds[0]);

    // Number of transfers to execute
    uint256 nTransfer = _tokenIds.length;

    // Last bin updated
    uint256 lastBin = bin;

    for (uint256 i = 1; i < nTransfer; i++) {
      (bin, index) = _tokenIds[i].getTokenBinIndex();

      // If new bin
      if (bin != lastBin) {
        // Update storage balance of previous bin
        packedTokenBalance[_from][lastBin] = balFrom;
        packedTokenBalance[_to][lastBin] = balTo;

        // Load current bin balance in memory
        balFrom = packedTokenBalance[_from][bin];
        balTo = packedTokenBalance[_to][bin];

        // Bin will be the most recent bin
        lastBin = bin;
      }

      // Update memory balance
      balFrom = balFrom.updateTokenBalance(index, _amounts[i], ObjectLib.Operations.SUB);
      balTo = balTo.updateTokenBalance(index, _amounts[i], ObjectLib.Operations.ADD);

      emit Transfer(_from, _to, _tokenIds[i]);
    }

    // Update storage of the last bin visited
    packedTokenBalance[_from][bin] = balFrom;
    packedTokenBalance[_to][bin] = balTo;

    // Emit batchTransfer event
    emit BatchTransfer(_from, _to, _tokenIds, _amounts);
  }

  function _transferFrom(address _from, address _to, uint256 _tokenId, uint256 _amount) internal {
    require(isApprovedOrOwner(msg.sender, _from, _tokenId), "Not approved");
    require(_amount <= balanceOf(_from, _tokenId), "Quantity greater than from balance");
    require(_to != address(0), "Invalid to address");

    _updateTokenBalance(_from, _tokenId, _amount, ObjectLib.Operations.SUB);
    _updateTokenBalance(_to, _tokenId, _amount, ObjectLib.Operations.ADD);
    emit Transfer(_from, _to, _tokenId);
    emit TransferWithQuantity(_from, _to, _tokenId, _amount);
  }

  function _checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes memory _data
  ) internal returns (bool) {
    if (!_to.isContract()) {
      return true;
    }

    bytes4 retval = IERC721OReceiver(_to).onERC721OReceived(msg.sender, _from, _tokenId, _amount, _data);
    return(retval == ERC721O_RECEIVED);
  }
}
