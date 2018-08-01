pragma solidity ^0.4.24;

contract Lottery {
    bytes32 public sentinelHash;
    uint256 public sentinelNumber;

    mapping (address => bytes32) hashByAddress;
    uint256[] public numbers;
    address[] public verifiedPlayers;

    address public owner;
    bool looping = true;
    enum LotteryState { Creating, Ready, Accept, Verify, Lock}
    LotteryState state;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    constructor() public {
        owner = msg.sender;
        state = LotteryState.Creating;
    }

    function presentHash(bytes32 x) public payable {
        require(state == LotteryState.Accept);
        require(msg.value > .001 ether);
        hashByAddress[msg.sender] = x;
    }

    function verifyNumber(uint256 number) public {
        require(state == LotteryState.Verify);
        require(keccak256(abi.encodePacked(number, msg.sender)) == hashByAddress[msg.sender]);
        verifiedPlayers.push(msg.sender);
        numbers.push(number);
    }

    function determineWinner() private {
        require(state == LotteryState.Lock);
        uint256 randomNumber = random();
        address winnerAddress = verifiedPlayers[randomNumber % verifiedPlayers.length];
        uint256 balanceToAward = address(this).balance/2;
        winnerAddress.transfer(balanceToAward);
        restart();
    }

    function random() private view returns (uint256) {
        uint256 randomNumber = sentinelNumber;
        for (uint8 i = 0; i < numbers.length; ++i) {
            randomNumber += numbers[i];
        }
        return randomNumber;
    }

    function restart() private {
        if (looping) {
            delete sentinelNumber;
            delete sentinelHash;
            delete numbers;
            delete verifiedPlayers;

            state = LotteryState.Ready;
        } else {
            end();
        }
    }

    // Sentinel commands
    function genHash(uint256 n) public view returns (bytes32) {
        return keccak256(abi.encodePacked(n, msg.sender));
    }

    function startAccepting(bytes32 x) restricted public {
        require(state == LotteryState.Ready);
        sentinelHash = x;
        state = LotteryState.Accept;
    }

    function endVerification(uint256 number) restricted public {
        require(state == LotteryState.Verify);
        require(keccak256(abi.encodePacked(number, msg.sender)) == sentinelHash);
        state = LotteryState.Lock;
        sentinelNumber = number;
        determineWinner();
    }

    // Contract management
    function ready() restricted public {
        require(state == LotteryState.Creating);
        state = LotteryState.Ready;
    }

    function verify() restricted public {
        require(state == LotteryState.Accept);
        state = LotteryState.Verify;
    }

    function loop(bool x) restricted public {
        looping = x;
    }

    function end() restricted public {
        selfdestruct(owner);
    }
}