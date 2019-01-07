import React from 'react';
import { Route, Link } from 'react-router-dom';

import ChallengesBody from '../Challenges/Body';
import ChallengeForm from '../Challenges/Form';

const menu = (props) => {
  const {account, web3, contract} = props;

  return (
    <div>
      <nav>
        <ul>
          <li className="menu">
            <Link to="/">My challenges</Link>
          </li>
          <li className="menu">
            <Link to="/challenges/new">New challenge</Link>
          </li>
        </ul>
      </nav>

      <Route
        exact path="/"
        render={(props) => <ChallengesBody {...props} account={account} web3={web3} />}
      />
      <Route
        exact path="/challenges/new"
        render={(props) => <ChallengeForm {...props} account={account} web3={web3} contract={contract}/>}
      />
    </div>
  )
}

export default menu;
