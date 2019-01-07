import React, { Component } from 'react';
import { BrowserRouter as Router } from 'react-router-dom';

import './App.sass';

import getWeb3 from './Authentication/Metamask';
import Navigation from './Navigation/Menu';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      web3: null,
      account: null,
      contract: null,
    };
  }

  componentDidMount = async () => {
    try {
      const web3 = await getWeb3();
      const accounts = await web3.eth.getAccounts();
      this.setState({ web3: web3, account: accounts[0] });
    } catch (error) {
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  }

  render() {
    const {web3, account} = this.state;
    if (!this.state.web3) {
      return  <div>Metamask is loading...</div>
    } else {
      return (
        <Router>
          <div className="App">
            <Navigation web3={web3} account={account} />
          </div>
        </Router>
      );
    }
  }
}

export default App;
