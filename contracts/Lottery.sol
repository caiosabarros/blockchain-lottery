//SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
    AggregatorV3Interface internal ethInUsdPriceFeed;
    /*your smart contract should reference AggregatorV3Interface, 
    which defines the external functions implemented by Data Feeds.*/
    address payable[] public players;
    uint256 public minimumUSD = 50; //50 USD *10**18 //50000000000000000000 = 50 ETH;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomness;
    address payable public recentWinner;

    constructor(
        address _priceFeed,
        address _VRFCoordinator,
        address _LINKToken,
        uint256 _fee,
        bytes32 _keyHash
    ) public VRFConsumerBase(_VRFCoordinator, _LINKToken) {
        ethInUsdPriceFeed = AggregatorV3Interface(_priceFeed);
        /* Network: Kovan, Aggregator: ETH/USD, Address: 0x9326BFA02ADD2366b30bacB125260Af641031331 */
        lottery_state = LOTTERY_STATE.CLOSED;
        fee = _fee;
        keyHash = _keyHash;
    }

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    LOTTERY_STATE public lottery_state;

    function enter() public payable {
        // function that enables address to participate in the lottery.
        require(lottery_state == LOTTERY_STATE.OPEN);
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        players.push(msg.sender);
    }

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can't open a new lottery right now!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function getEntranceFee() public view returns (uint256) {
        //ETH/USD, which returns 140330173736 = $1,403.30173736 = 8 decimals.
        //1ETH = 10**18 WEI
        (, int256 price, , , ) = ethInUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10; //adjusted to WEI

        uint256 costToEnter = (minimumUSD * 10**18) / adjustedPrice;
        // (140330173736*10**10)*1/1000000000000000000 = 1403.30173736 USD
        return costToEnter;
        /*It comes with 8 decimals. So, to converto to WEI, we only add 10 decimals.*/
    }

    function endLottery() public onlyOwner {
        require(lottery_state == LOTTERY_STATE.OPEN);
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER);
        require(_randomness > 0, "random-not-found");
        uint256 indexOfWinner = _randomness % players.length;

        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);

        players = new address payable[](0); //zero the address of players.
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness; //Not necessary. I only want to keep track of the number;
    }
}

/*
2000 USD - 1 ETH - 10**18 WEI
50 USD   -- x ---- y 
x = 50*10**18/getPrice()
*/
