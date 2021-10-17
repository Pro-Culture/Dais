// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
 library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

   
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

   
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

   
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

  
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

  
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

   
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

   
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract Dais is Ownable{
    
    using SafeMath for uint256;
    struct investorInfo{
        uint256 amount;
        uint256 timeFrame;
        uint256 ROI;
        uint256 timeInvested;
    }
 
    
    bool public IPO;
    
    uint256 public limitInvestment;
    
    uint256 public ROIpercent;
    
    uint256 public investorSlot;
    
    uint256 public investTimeFrame;
    
    mapping(address => investorInfo) iInfo;
    mapping(address => uint256) keep;
    
    function setIPO() public onlyOwner {
        IPO = true;
    }
    function endIPO() public onlyOwner {
        IPO = false;
    }
    function setInvestorSlot(uint256 num) public onlyOwner {
       require(IPO, ' IPO is false, Not announced Yet');
       investorSlot = num;
    }
    function setTimeFrame(uint256 timeFrame) public onlyOwner {
        require(IPO, 'can not set time frame if IPO is false');
        uint time = block.timestamp.add(30 days);
        require(timeFrame >= time, 'Time set is INVALID, MUST BE MORE THAN A MONTH');
        investTimeFrame = timeFrame;
    }
    function setROI(uint256 amount) public onlyOwner {
        require(amount >= 1,'INVALID');
        ROIpercent = amount;
    }
    function setInvestmentLimit(uint256 amount) public onlyOwner {
        limitInvestment = amount;
    }
    function invest() public payable {
        require(IPO, 'IPO is not available');
        require(investorSlot > 0, "investor slot is completed");
        require(msg.value >= limitInvestment,'Sorry can not Invest');
        uint256 _myROI = msg.value.mul(ROIpercent).div(100);
        payable(owner()).transfer(msg.value.mul(70).div(100));
        uint256 iTimeFrame =  block.timestamp.add(investTimeFrame);
        investorInfo memory iI = investorInfo(msg.value,_myROI,iTimeFrame,block.timestamp);
        keep[msg.sender] = keep[msg.sender].add(_myROI);
        iInfo[msg.sender] = iI;
        investorSlot = investorSlot.sub(1);
    }
    function claimROI() public {
        investorInfo memory iI = iInfo[msg.sender];
        require(iI.timeInvested < 2 days, " can not claim ROI till 2 days");
        uint256 _myROI = keep[msg.sender];
        payable(msg.sender).transfer(_myROI);
        keep[msg.sender] = keep[msg.sender].sub(_myROI);
        iInfo[msg.sender] = iI;
    }
    function myROI() public view returns(uint256) {
        return keep[msg.sender];
    }
}