// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract SendEther{

constructor() payable{}
 receive () external payable{}
 address payable public admin= payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
 //address payable public admin = payable(address(this));
//address payable public admin =0x838F9b8228a5C95a7c431bcDAb58E289f5D2A4DC;


function sendViaTransfer(address payable _to) external payable {

    _to.transfer(10);
}
}

contract EthReceiver {

event Log(uint amount, uint gas);
receive() external payable {

    emit Log(msg.value, gasleft());

}

}