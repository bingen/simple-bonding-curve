pragma solidity ^0.4.24;

import "../BancorFormula.sol";


contract BancorFormulaWrapper is BancorFormula {
    function powerExt(uint256 _baseN, uint256 _baseD, uint32 _expN, uint32 _expD) external view returns (uint256, uint8) {
        return power(_baseN, _baseD, _expN, _expD);
    }
}
