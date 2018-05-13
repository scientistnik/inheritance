pragma solidity ^0.4.21;

import "./zeppelin/contracts/ownership/Ownable.sol";
import "./Testamentum.sol";

contract Testator is Ownable {

  bool public dead = false;
  uint public deadTime = 0;
  Testamentum public testamentum;

  modifier isDead() {
    require (dead);
    _; 
  }

  modifier testamentumOnly() {
    require (address(testamentum) == msg.sender);
    _; 
  }

  function setDead() testamentumOnly public {
    dead = true;
    deadTime = now;
  }

  function newTestamentum() onlyOwner public {
    if (testamentum != address(0x0))
      testamentum.block();

    testamentum = new Testamentum();
  }

  function giveBalance() isDead testamentumOnly public {
    address(testamentum).transfer(address(this).balance);
  }

  function execByteCode(uint amount, bytes bytecode) onlyOwner public {
    address(this).call.value(amount)(bytecode);
  }

  function() payable public {}
}
