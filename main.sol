pragma solidity ^0.8.16;

contract SimpleAuction{
    // paramaters of auction
    address payable public beneficiary; //The one who selling sth in the auction
    uint auctionEndTime; 

    //Current state of the auctionEndTime
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public pendingReturns; //mapping where you put the address and get the integer as an output
    bool ended = false;
    event HighestBidIncrease(address bidder, uint amount);//Action when the bidder puts his amount
    event AuctionEnded(address winner, uint amount); //Action when the winner win with certain amount of money
    constructor(uint _biddingTime, address payable _beneficiary){//constructor is a function that is to initialize state variables in a contract
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid()public payable{
        if(block.timestamp > auctionEndTime){
            revert("The auction has finished.");// function that stops the function where it is
        }
        if(msg.value <= highestBid){
            revert("There is already higher or equal bid.");
        }
        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender, msg.value);//Emit  stores the arguments passed in transaction logs
    }
    function withdraw()public returns (bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }
    function auctionEnd()public{
        if(block.timestamp < auctionEndTime){
            revert("The auction has not ended yet.");
        }
        if(ended){
            revert("The function - auctionEnded, has been already called.");
        }
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid); 
    }
}
