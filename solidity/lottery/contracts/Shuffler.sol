pragma solidity ^0.4.25;
contract Shuffler {
    uint8[] cards;
    uint256 randomSeed;

    constructor() public {
        for (uint8 i = 0; i < 52; i++) {
            cards.push(i);
        }
        randomSeed = 1;
    }

    function draw() returns (uint8) {
        return _draw(cards, randomSeed);
    }

    function _draw(uint8[] cs, uint256 rs) private returns (uint8) {
        return uint8(keccak256(toBytes(rs))) % 52 + 1;
    }

    function toBytes(uint256 x) private pure returns (bytes b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }
}