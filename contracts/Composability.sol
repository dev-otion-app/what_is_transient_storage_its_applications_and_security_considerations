// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Composability{
    uint256 counter;

    function memory_composable_counter() external pure{
        assembly{
            if mload(0){
                mstore(0,add(mload(0),1))
            }
            if iszero(mload(0)){
                mstore(0,1)
            }
        }
    }

    function storage_composable_counter() external{
        counter++;
    }

    function transient_storage_not_composable_counter() external{
        assembly{
            if tload(0){
                tstore(0,add(tload(0),1))
            }
            if iszero(tload(0)){
                tstore(0,1)
            }
        }
    }

    function clear_transient_storage() public{
        assembly{
            tstore(0,0)
        }
    }
}
