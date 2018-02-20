pragma solidity ^0.4.11;
contract KickStarter {
    
    uint public auctionEnd;
    address public beneficiary;
    uint public target;
    uint public progress;
    
    mapping(address => uint) funders;
    
    bool ended;
    bool goalReached;
    
    event GoalReached(address beneficiary, bool goalReached);
    event KickstarterEnded(address product, uint progress);
    event FundTransfer(address user, uint amount);
    
    function KickStarter(uint _biddingTime, address _beneficiary, uint _target) public {
        auctionEnd = _biddingTime + now;
        beneficiary = _beneficiary;
        target = _target;
        progress = 0;
        goalReached = false;
    }
    
    function fund() public payable {
        require(now <= auctionEnd);
        progress += msg.value;
        funders[msg.sender] += msg.value;
        
        if (progress > target) {
            goalReached = true;
        } 
    }
    
    function auctionEnd() public {
        require(now > auctionEnd);
        
        ended = true;
        KickstarterEnded(beneficiary, progress);
        
        if (msg.sender == beneficiary && goalReached) {
            if (beneficiary.send(progress)) {
                GoalReached(beneficiary, true);
                FundTransfer(beneficiary, progress);
                progress = 0;
            } else {
                goalReached = false;
                GoalReached(beneficiary, false);
            }
        }
        
        if (!goalReached) {
            uint amount = funders[msg.sender];
            funders[msg.sender] = 0;
            if (amount > 0) {
                msg.sender.transfer(amount);
                FundTransfer(msg.sender, amount);
            } else {
                funders[msg.sender] = amount;
            }
        }
        
    }
}
