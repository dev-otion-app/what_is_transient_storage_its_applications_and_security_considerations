// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Caller{
    error CustomError();
    function make_calls(address callee_contract) external returns(uint256 a, uint256 b){
        assembly{
            tstore(0,1)
        }
        (bool success1, ) = callee_contract.call(abi.encodeWithSignature('called()'));
        if (!success1){
            revert CustomError();
        }
        assembly{
            a := tload(0)
        }
        (bool success2, ) = callee_contract.delegatecall(abi.encodeWithSignature('delegatecalled()'));
        if (!success2){
            revert CustomError();
        }
        assembly{
            b := tload(0)
        }
    }
}

contract Callee{
    function called() external{
        assembly{
            tstore(0,2)
        }
    }

    function delegatecalled() external{
        assembly{
            tstore(0,3)
        }
    }
}