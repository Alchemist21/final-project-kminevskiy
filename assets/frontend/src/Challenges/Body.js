import React from 'react';
import axios from 'axios';

import './Body.sass'
import List from './List';

const ENDPOINT = 'http://localhost:4000/api/v1/challenges';

class Body extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      challenges: [],
      account: props.account,
      web3: props.web3,
    }

    this.pullChallenges = this.pullChallenges.bind(this);
    this.intervalId = setInterval(this.pullChallenges.bind(this), 10000);
  }

  componentWillUnmount() {
    clearInterval(this.intervalId);
  }

  componentDidMount() {
    this.pullChallenges();
  }

  updateChallenges() {
    this.pullChallenges();
  }

  pullChallenges() {
    axios.get(ENDPOINT)
      .then(result => this.setState({
        challenges: result.data.data
      }))
  }

  render() {
    const {challenges, web3} = this.state;
    return <List
              challenges={challenges}
              web3={web3}
              onChallengeUpdate={this.pullChallenges} />
  }
}

export default Body;
