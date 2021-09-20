The coding process was divided into three parts:

1.Developing the Smart Contract
2.Deploying

1. Developing the Smart Contract
    I found it challeging at first, but after reading the documentation and seeing the examples 
on the tutorial on how to use the VRFConsumerBase, the process became much easier. The develpoment
part can be summarized in:
 -Importing Dependencies
 -Writing the enter, getEntranceFee functions and startLottery function
 -Writing the endLottery function, where I used the VRFConsumerBase from Chainlink to generate a random
 number to select the winner of the lottery. Doing this helped me to understand the requestRandomness and fulfillRandomness function.
 -Compiling using ```brownie compile``` to correct errors in the code.

2. Deploying
 - Editing the get_account() function in order to make it broad enough to eveng grasp the accounts in our local 
 machine that can be found by the command ```brownie accounts list``.
 - Creating a mock to retrieve the data we need that can only be obtained by ChainLink on a real or testnetwork,
 but not by a local network. So, this mock made it possible for me to do that.
   It is important to note the distinctions between our networks here:
   Ethereum - ganache-local : we're using the addresses generated in my local-machine through Ganache on the Ethereum network.
   Development - mainnet-fork-dev: we're using the mainnet actual parameters, timing, difficulty, and on in our local machine.

    It was very good to get my feet wet on how to develop a good useful smart contract and also deploying it making some interactions with it, like creating the contract by funding it, starting the lottery, and ending the lottery.
