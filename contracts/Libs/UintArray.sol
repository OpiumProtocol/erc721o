pragma solidity ^0.5.4;

library UintArray {
  function indexOf(uint256[] memory A, uint256 a) internal pure returns (uint256, bool) {
    uint256 length = A.length;
    for (uint256 i = 0; i < length; i++) {
      if (A[i] == a) {
        return (i, true);
      }
    }
    return (0, false);
  }

  function contains(uint256[] memory A, uint256 a) internal pure returns (bool) {
    (, bool isIn) = indexOf(A, a);
    return isIn;
  }

  function difference(uint256[] memory A, uint256[] memory B) internal pure returns (uint256[] memory, uint256[] memory) {
    uint256 length = A.length;
    bool[] memory includeMap = new bool[](length);
    uint256 count = 0;
    // First count the new length because can't push for in-memory arrays
    for (uint256 i = 0; i < length; i++) {
      uint256 e = A[i];
      if (!contains(B, e)) {
        includeMap[i] = true;
        count++;
      }
    }
    uint256[] memory newUints = new uint256[](count);
    uint256[] memory newUintsIdxs = new uint256[](count);
    uint256 j = 0;
    for (uint256 i = 0; i < length; i++) {
      if (includeMap[i]) {
        newUints[j] = A[i];
        newUintsIdxs[j] = i;
        j++;
      }
    }
    return (newUints, newUintsIdxs);
  }

  function intersect(uint256[] memory A, uint256[] memory B) internal pure returns (uint256[] memory, uint256[] memory, uint256[] memory) {
    uint256 length = A.length;
    bool[] memory includeMap = new bool[](length);
    uint256 newLength = 0;
    for (uint256 i = 0; i < length; i++) {
      if (contains(B, A[i])) {
        includeMap[i] = true;
        newLength++;
      }
    }
    uint256[] memory newUints = new uint256[](newLength);
    uint256[] memory newUintsAIdxs = new uint256[](newLength);
    uint256[] memory newUintsBIdxs = new uint256[](newLength);
    uint256 j = 0;
    for (uint256 i = 0; i < length; i++) {
      if (includeMap[i]) {
        newUints[j] = A[i];
        newUintsAIdxs[j] = i;
        (newUintsBIdxs[j], ) = indexOf(B, A[i]);
        j++;
      }
    }
    return (newUints, newUintsAIdxs, newUintsBIdxs);
  }

  function isUnique(uint256[] memory A) internal pure returns (bool) {
        uint256 length = A.length;

        for (uint256 i = 0; i < length; i++) {
            (uint256 idx, bool isIn) = indexOf(A, A[i]);

            if (isIn && idx < i) {
                return false;
            }
        }

        return true;
    }
}
