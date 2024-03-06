// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // You need to have this contract installed in your project

// This contract is just used for demonstration purposes of transient storage. Typical token validations are skipped in order to keep the code minimal. Please, note that this doesn't mean these validations don't have to be applied when using transient storage

contract AttackedToken is ERC20{

    constructor() ERC20("AttackedToken", "ATKN"){}

    function getTokens() public payable{
        _mint(_msgSender(), msg.value);
    }

    function transientApprove(address spender, uint256 value) public {
        address owner = _msgSender();
        _transientApprove(owner, spender, value);
    }

    function _transientApprove(address owner, address spender, uint256 value) internal{
        assembly{
            // The transient mapping will follow the same convention as the usual storage mapping, so suposing there's no other transient storage item in the contract, the storage slot for the outer mapping slot
            mstore(0, owner)
            mstore(0x20, 0)
            mstore(0x20, keccak256(0,0x40)) // Store in 0x20 the inner mapping slot
            mstore(0, spender) // And in 0 the spender address, so keccak256(0,0x40) now points to the slot corresponding to transientmapping[msg.sender][spender]
            tstore(keccak256(0,0x40),value) // Store the allowance, only 100 gas!
        }
    } 

    function transientAllowance(address from, address spender) public view returns(uint256 value){
        assembly{
            mstore(0, from)
            mstore(0x20, 0)
            mstore(0x20, keccak256(0,0x40))
            mstore(0, spender)
            value := tload(keccak256(0,0x40))
        }
    }

    function transientApprovedWithdraw(address from, address to) public{
        address spender = _msgSender();
        // This function allow the spender to send ETH on behalf of 'from' from the contract. The related tokens owned by 'from' are burned. Transient storage hides a reentrancy attack through the transfer function ... (read the post at dev-otion.com to find out why!)
        bool success = payable(to).send(transientAllowance(from, spender));
        require(success);
        _burn(from,transientAllowance(from, spender));
        _transientApprove(from, spender, 0);
    }

}


contract Attacker1 {
    fallback() external payable{
        AttackedToken token = AttackedToken("token contract address");
        token.transientApprove(address(this), 0); 
    }
}