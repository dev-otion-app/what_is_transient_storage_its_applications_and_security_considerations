// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


contract UltraCheapReentrancyGuard{

    modifier guard{
        assembly{
            if tload(0) { revert(0,0) }
            tstore(0,1)
        }
        _;
        assembly{
            tstore(0,0)
        }
    }

}