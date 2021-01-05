pragma solidity ^0.5.4;

import "openzeppelin-solidity/contracts/utils/Address.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";

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
    require(_to != address(0), "Invalid to address");

    // Number of transfers to execute
    uint256 nTransfer = _tokenIds.length;

    // Don't do useless calculations
    if (_from == _to) {
      for (uint256 i = 0; i < nTransfer; i++) {
        emit Transfer(_from, _to, _tokenIds[i]);
        emit TransferWithQuantity(_from, _to, _tokenIds[i], _amounts[i]);
      }
      return;
    }

    for (uint256 i = 0; i < nTransfer; i++) {
      require(_amounts[i] <= balanceOf(_from, _tokenIds[i]), "Quantity greater than from balance");
      _updateTokenBalance(_from, _tokenIds[i], _amounts[i], ObjectLib.Operations.SUB);
      _updateTokenBalance(_to, _tokenIds[i], _amounts[i], ObjectLib.Operations.ADD);

      emit Transfer(_from, _to, _tokenIds[i]);
      emit TransferWithQuantity(_from, _to, _tokenIds[i], _amounts[i]);
    }

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
