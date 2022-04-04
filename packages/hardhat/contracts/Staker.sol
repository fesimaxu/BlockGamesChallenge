// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <= 0.9.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  uint256 public constant threshold = 1 wei;

  //staking deadline, After this deadline, anyone sends funds
  //tp the other contracts
  uint256 public deadline = block.timestamp + 180 seconds;

  //emits event each time 
  event Stake(address indexed sender, uint256 amount);

  //Balances of the users' staked funds
  mapping ( address => uint256 ) public balances;

  function stake() public payable {
    //update the users' balance
    balances[msg.sender] += msg.value;

    //emit the event to notify the blockchain that we have correctly skated ssome fund for the user
    emit Stake(msg.sender, msg.value); 
  }



  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() public {

    require(timeLeft() == 0, "Deadline is not yet expired");

    uint256 contractBalance = address(this).balance;

    require(contractBalance >= threshold, "Threshold is not reached");

    (bool sent,) = address(exampleExternalContract).call{value: contractBalance}(abi.encodeWithSignature("complete()"));
    require(sent,"exampleExternalContract.complete failed :(");
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw(address payable depositor) public {
    uint256 userBalance = balances[depositor];

    require(timeLeft() == 0, "Deadline not expired yet");

    require(userBalance > 0, "No balance to withdraw");

    balances[depositor] = 0;

    (bool sent,) = depositor.call{value: userBalance}("");
    require(sent, "Failed to send balance to the user");
  }

  // Add a `withdraw()` function to let users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256 timeLeft) {
    return deadline >= block.timestamp ? deadline - block.timestamp: 0;

  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable{
    stake();
  }


}
