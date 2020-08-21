pragma solidity ^0.4.24;

import "../lib/FixedPointMath.sol";


contract FixedPointMathWrapper {
    uint256 private constant ROOT_ITERATIONS = 3;
    uint256 private constant ROOT_ERROR_THRESHOLD = 10**12; //1e-6

    using FixedPointMath for uint256;

    function multiplyFixed(uint256 a, uint256 b) external pure returns (uint256 result) {
        return a.multiplyFixed(b);
    }

    function divideFixed(uint256 a, uint256 b) external pure returns (uint256) {
        return a.divideFixed(b);
    }

    function powFixed(uint256 base, uint256 exp) external pure returns (uint256 result) {
        return base.powFixed(exp);
    }

    function rootFixed(uint256 base, uint256 n) external pure returns (uint256) {
        return base.rootFixed(n, ROOT_ERROR_THRESHOLD);
    }

    function rootFixed2(uint256 base, uint256 n) external pure returns (uint256) {
        return base.rootFixed2(n, ROOT_ITERATIONS, ROOT_ERROR_THRESHOLD);
    }
}
