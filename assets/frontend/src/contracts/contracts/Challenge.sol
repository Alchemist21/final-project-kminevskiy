pragma solidity >=0.4.0 <0.6.0;

import "./SafeMath.sol";

/** @title Challenge contract */
contract Challenge {
    using SafeMath for uint;
    event ExtendExpiration(uint newExpiration);
    event CompleteChallenge(bool flag);
    event FlushBalance(uint balance);

    address payable owner;
    bool public extended;
    bool public completed;
    bool public paused;
    uint public finalBalance;

    struct Data {
        address payable challenger;
        address payable contender;
        address payable trustee;
        string description;
        uint expirationDate;
    }

    Data private data;

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier notExtended() {
        require(extended == false);
        _;
    }

    modifier notExpired() {
        require(now < data.expirationDate);
        _;
    }

    modifier notCompleted() {
        require(!completed);
        _;
    }

    modifier notPaused() {
        require(!paused);
        _;
    }

    /*
     * @param _challenger Challenger's address
     * @param _contender Contender's address
     * @param _days Number of days the contract is valid for
     * @param _hours Number of hours the contract is valid for
     * @param _minutes Number of minutes the contract is valid for
     * @param _description A short description of the challenge
    */
    constructor(
        address payable _challenger,
        address payable _contender,
        uint _days,
        uint _hours,
        uint _minutes,
        string memory _description)
        payable
        public {

        uint expirationConversion = calculateExpiration(_days, _hours, _minutes);
        data = Data({challenger: _challenger,
                     contender: _contender,
                     trustee: address(this),
                     expirationDate: expirationConversion,
                     description: _description});
        owner = msg.sender;
    }

    /** @dev Private function to normalize expiration timestamp
      * @param _days Number of days
      * @param _hours Number of hours
      * @param _minutes Number of minutes
      * @return New expiration Unix timestamp
    */
    function calculateExpiration(
        uint _days,
        uint _hours,
        uint _minutes)
        private
        view
        returns (uint) {

        return now + (_days * 1 days) + (_hours * 1 hours) + (_minutes * 1 minutes);
    }

    /** @dev Public function to modify expiration date
      * @param _days Number of days
      * @param _hours Number of hours
      * @param _minutes Number of minutes
      * @return Boolean flag
    */
    function extendExpiration(
        uint _days,
        uint _hours,
        uint _minutes)
        public
        isOwner()
        notExtended()
        notPaused()
        returns (bool) {

        extended = true;
        if (now > data.expirationDate) {
            data.expirationDate += calculateExpiration(_days, _hours, _minutes);
        } else {
            data.expirationDate = calculateExpiration(_days, _hours, _minutes);
        }

        emit ExtendExpiration(data.expirationDate);
        return true;
    }

    /** @dev Complete the challenge and transfer balance to the contender's account
      * @return Boolean flag
    */
    function complete()
        public
        notExpired()
        notCompleted()
        isOwner()
        notPaused()
        returns (bool) {

        completed = true;
        if (data.trustee.balance > 0) {
            finalBalance = data.trustee.balance;
            data.contender.transfer(data.trustee.balance);
        }

        emit CompleteChallenge(true);
        return true;
    }

    /** @dev Return current contract balance
      * @return Balance
    */
    function challengeBalance() view public returns (uint) {
        return data.trustee.balance;
    }

    /** @dev Check if the contract has expired
      * @return Boolean flag
    */
    function expired() public view returns (bool) {
        if (now >= data.expirationDate) {
            return true;
        }
        return false;
    }

    /** @dev Return contract expiration date
      * @return Expiration date timestamp
    */
    function getExpirationDate() public view returns (uint) {
        return data.expirationDate;
    }

    /** @dev Return contract description
      * @return Description string
    */
    function getDescription() public view returns (string memory) {
        return data.description;
    }

    /** @dev Return contract initiator (challenger)
      * @return Initiator (challenger) address
    */
    function getInitiator() public view returns (address) {
        return data.challenger;
    }

    /** @dev Return contract contender
      * @return Contender address
    */
    function getContender() public view returns (address) {
        return data.contender;
    }

    /** @dev Flush contract balance to "recharge" the deployment account
      * @return Boolean flag
    */
    function flushBalance()
        public
        isOwner()
        returns (bool) {
        completed = true;
        emit FlushBalance(data.trustee.balance);
        owner.transfer(data.trustee.balance);
        return true;
    }


    /** @dev Pauses the contract in case of found vulnerability
      * @return Boolean flag
    */
    function switchPause()
        public
        isOwner()
        returns (bool) {

        if (paused) {
            paused = false;
            return false;
        }
        paused = true;
        return true;
    }

    function() external payable {}
}
