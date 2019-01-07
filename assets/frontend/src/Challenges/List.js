import React from 'react';

import Challenge from './Challenge';

class List extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      account: null
    }
    this.checkInterval = setInterval(this.checkMetamaskUpdate.bind(this), 2000)
  }

  componentDidMount() {
    this.checkMetamaskUpdate();
  }

  componentWillUnmount() {
    clearInterval(this.checkInterval);
  }

  checkMetamaskUpdate() {
    this.props.web3.eth.getAccounts((err, accounts) => {
      this.setState({account: accounts[0]})
    })
  }

  render() {
    let myChallenges = [];
    let otherChallenges = [];
    const {challenges, web3, onChallengeUpdate} = this.props;
    const account = this.state.account;

    challenges.forEach(c => {
      if (account === c.contender) {
        myChallenges.push(<Challenge
                            key={c.id}
                            web3={web3}
                            challenge={c}
                            account={account}
                            onChallengeUpdate={onChallengeUpdate}/>)
      } else {
        otherChallenges.push(<Challenge key={c.id} web3={web3} challenge={c} account={account} />)
      }
    })

    return (
      <div className="challenge-lists">
        {myChallenges.length > 0 &&
        <div>
          <h3>My challenges</h3>
          <ul>{myChallenges}</ul>
        </div>
        }
        {otherChallenges.length > 0 &&
        <div>
          <h3>Other challenges</h3>
          <ul>{otherChallenges}</ul>
        </div>
        }
      </div>
    )
  }
}

export default List;
