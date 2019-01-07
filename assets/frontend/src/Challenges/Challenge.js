import React from 'react';
import { withRouter } from 'react-router-dom';
import ChallengeContract from '../contracts/build/contracts/Challenge.json';

const axios = require('axios');

const ENDPOINT = "http://localhost:4000/api/v1/challenges/";
const ROPSTEN = "https://ropsten.etherscan.io/address/";

class Challenge extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      contract: null,
      expiration: new Date(props.challenge.expirationDate).getTime(),
      days: 0,
      hours: 0,
      minutes: 0,
      balance: 0,
      balanceInterval: null
    };

    this.timerInterval = setInterval(this.expiresIn, 1000);
  }

  onUpdate = () => {
    this.props.onChallengeUpdate();
  }

  componentWillUnmount() {
    clearInterval(this.timerInterval);
    clearInterval(this.state.balanceInterval);
    clearInterval(this.state.rewardInterval);
  }

  componentDidMount() {
    const {web3, challenge} = this.props;
    let c, reward, balance, boundB, boundR, balanceInterval, rewardInterval;
    if (challenge.address) {
      c = new web3.eth.Contract(ChallengeContract.abi, challenge.address);
      balance = this.getChallengeBalance(c);
      boundB = this.getChallengeBalance.bind(this, c);
      balanceInterval = setInterval(boundB, 5000);

      reward = this.getFinalBalance(c);
      boundR = this.getFinalBalance.bind(this, c);
      rewardInterval = setInterval(boundR, 5000);
    }

    this.setState(() => {
      return {
        contract: c,
        balance: balance || 0,
        reward: reward || 0,
        balanceInterval: balanceInterval,
        rewardInterval: rewardInterval
      }
    })
  }

  setStatus = () => {
    const challenge = this.props.challenge;
    let status;
    if (challenge.finished) {
      status = 'finished';
    } else if (challenge.expired) {
      status = 'expired';
    } else {
      status = 'active';
    }

    return status;
  }

  matchCallerAddress = () => {
    const {account, challenge} = this.props;
    let address;

    if (challenge.contender === account) {
      address = challenge.challenger;
    } else if (challenge.challenger === account) {
      address = challenge.contender;
    } else {
      address = challenge.challenger
    }

    return address;
  }

  acceptChallenge = () => {
    const challenge = this.props.challenge;

    axios.post(ENDPOINT + challenge.id + '/accept',
      {contender: challenge.contender})
      .then(_ => {
        this.onUpdate();
      })
  }

  completeChallenge = () => {
    const challenge = this.props.challenge;

    axios.put(ENDPOINT + challenge.id + '/complete',
      {contender: challenge.contender})
      .then(_ => {
        this.onUpdate();
      })
  }

  canBeFinished = () => {
    const {account, challenge} = this.props;

    return challenge.finished &&
      challenge.accepted &&
      !challenge.expired &&
      !challenge.confirmed &&
      challenge.challenger === account
  }

  finishChallenge = () => {
    const challenge = this.props.challenge;

    axios.put(ENDPOINT + challenge.id + '/finish',
      {challenger: challenge.challenger})
      .then(_ => {
        this.onUpdate();
      })

  }

  canBeCompleted = () => {
    const {account, challenge} = this.props;

    return !challenge.finished &&
      !challenge.expired &&
      challenge.contender === account &&
      challenge.accepted &&
      challenge.address
  }

  canBeAccepted = () => {
    const {account, challenge} = this.props;

    return !challenge.accepted && account === challenge.contender;
  }

  getFinalBalance = (contract) => {
    const account = this.props.account;

    contract.methods.finalBalance().call({from: account})
      .then(result => {
        this.setState({
          reward: (result / 10 ** 18).toFixed(5)
        })
      })
  }

  getChallengeBalance = (contract) => {
    const account = this.props.account;

    contract.methods.challengeBalance().call({from: account})
      .then(result => {
        this.setState({
          balance: (result / 10 ** 18).toFixed(5)
        })
      })
  }

  canContribute = () => {
    const {challenge, account} = this.props;

    return challenge.contender !== account &&
      !challenge.expired &&
      !challenge.finished &&
      challenge.address;
  }

  contributeToChallenge = () => {
    const {account, challenge, web3} = this.props;

    web3.eth.sendTransaction({from: account,
      to: challenge.address,
      value: '10000000000000000'})
  }

  expiresIn = () => {
    const end = this.state.expiration;
    const now = new Date().getTime();
    const diff = end - now;

    if (now < end) {
      this.setState({
        days: Math.floor(diff / (1000 * 60 * 60 * 24)),
        hours: Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)),
        minutes: Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60)),
      })
    }
  }

  expirationString = () => {
    const {days, hours, minutes} = this.state;
    const challenge = this.props.challenge;

    if (challenge.expired || challenge.finished) {
      return 'n/a';
    } else if (!challenge.accepted) {
      return `If accepted, has to be finished in ${challenge.days} days, ${challenge.hours} hours and ${challenge.minutes} minutes.`;
    } else {
      return `${days} days, ${hours} hours and ${minutes} minutes.`;
    }
  }

  render() {
    const challenge = this.props.challenge;
    const {balance, reward} = this.state;

    return (
      <li className="challenges">
        <h3 className={this.setStatus()}>
          <a className="challenge-link"
             href={ROPSTEN + challenge.address}
             target="_blank" rel="noopener noreferrer">
            {challenge.description}
          </a>
        </h3>
        {challenge.address &&
        <span>Challenge address: {challenge.address}</span>
        }
        <span>Who: {this.matchCallerAddress()}</span>
        <span>Expires in: {this.expirationString()} </span>
        <span>Balance: {balance} ether.</span>
        <span>Reward: {reward} ether.</span>

        <div className="button-container">
          {this.canBeAccepted() &&
          <button className="accept-button" onClick={this.acceptChallenge}>Accept</button>
          }
          {this.canBeCompleted() &&
          <button className="accept-button" onClick={this.completeChallenge}>Complete</button>
          }
          {this.canBeFinished() &&
          <button className="accept-button" onClick={this.finishChallenge}>Finish</button>
          }
          {this.canContribute() &&
          <button className="accept-button" onClick={this.contributeToChallenge}>Contribute</button>
          }
        </div>
      </li>
    )
  }
}

export default withRouter(Challenge);
