pragma solidity ^0.4.21;

import "./zeppelin/contracts/ownership/Ownable.sol";
import "./Testator.sol";

contract Testamentum is Ownable {

  struct Relative {
    address relative;
    uint percent;
  }

  Relative[] relatives;
  bool[] signaling;
  uint waitAfterDead = 7 * 24 * 60;

  mapping (address => uint) witnessBalances;
  uint public minimumPledge;
  uint witnessCount = 0;
  uint minimumWitnessCount = 0;
  uint quantity = 0;

  event SignalingOfDead(address deadAddress);

  modifier relativesOnly() {
    bool isRelative = false;
    for(uint i = 0; i < relatives.length; i++) {
      if (relatives[i].relative == msg.sender) {
        isRelative = true;
        break;
      }
    }
    
    require (isRelative);
    _;
  }

  function setWitnessCount(uint minimum) onlyOwner public {
    minimumWitnessCount = minimum;
  }

  function setPledge(uint pledge) onlyOwner public {
    minimumPledge = pledge;
  }
  
  function setRelatives(address[] addresses, uint[] percents) onlyOwner public {
    for (uint i = 0; i < addresses.length; i++)
      relatives.push(Relative({relative: addresses[i], percent: percents[i]}));
  }

  function signalingOfDead() relativesOnly {
    for (uint i = 0; i < relatives.length; i++) {
      if (relatives[i].relative == msg.sender){
        quantity ++;
        signaling[i] = true;
        break;
      }
    }

    if (quantity * 2 >= relatives.length)
      emit SignalingOfDead(this);
  }

  function witnessAgree() payable public {

    require (quantity * 2 >= relatives.length &&
              msg.value > minimumPledge && 
              witnessBalances[msg.sender] == 0);

    witnessBalances[msg.sender] = msg.value;
    witnessCount += 1;

    if (address(this).balance >= address(owner).balance &&
        witnessCount >= minimumWitnessCount)
      Testator(owner).setDead();
  }

  function realize() relativesOnly {
    require (Testator(owner).deadTime() + waitAfterDead <= now);

    Testator(owner).giveBalance();
    uint i = 0;
    uint[] values;

    for (; i < relatives.length; i++)
      values[i] = relatives[i].percent * address(this).balance / 100 / 100;

    for (i = 0; i < relatives.length; i++)
      relatives[i].relative.transfer(values[i]);

    //witness transfer balance
    //if (address(this).balance > 0)

  }

  function block() {
    address(owner).transfer(address(this).balance);
  }

  function() onlyOwner payable public {}
}