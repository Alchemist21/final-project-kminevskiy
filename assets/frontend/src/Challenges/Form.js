import React from 'react';
import './Form.sass';

const axios = require('axios');

class Form extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      account: '',
      description: '',
      contender: '',
      days: '0',
      hours: '0',
      minutes: '0'
    }

    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.interval = setInterval(this.checkMetamaskUpdate.bind(this), 2000);
  }

  handleInputChange(event) {
    const value = event.target.value;
    const name = event.target.name;

    this.setState({
      [name]: value
    })
  }

  handleSubmit = async (event) => {
    event.preventDefault();
    const { description, days, hours, minutes, contender } = this.state;
    axios.post("http://localhost:4000/api/v1/challenges",
      {challenge: {
        description: description,
        days: days,
        hours: hours,
        minutes: minutes,
        challenger: this.state.account,
        contender: contender
      }})
      .then(_ => {
        this.props.history.push("/")
      })
  }

  componentDidMount() {
    this.checkMetamaskUpdate();
  }

  componentWillUnmount() {
    clearInterval(this.interval);
  }

  checkMetamaskUpdate(interval) {
    this.props.web3.eth.getAccounts((err, accounts) => {
      this.setState({
        account: accounts[0]
      })
    })
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          Description:&nbsp;
          <input
            name="description"
            value={this.state.description}
            onChange={this.handleInputChange} />
        </label>
        <br />
        <label>
          Your address:&nbsp;
          <input
            name="address"
            value={this.state.account}
            disabled={true} />
        </label>
        <br />
        <label>
          Contender address:&nbsp;
          <input
            name="contender"
            value={this.state.contender}
            onChange={this.handleInputChange} />
        </label>
        <br />
        <label>
          Days to finish challenge:&nbsp;
          <input
            placeholder="0"
            name="days"
            type="number"
            min="0"
            onChange={this.handleInputChange} />
        </label>
        <br />
        <label>
          Hours to finish challenge:&nbsp;
          <input
            placeholder="0"
            name="hours"
            type="number"
            min="0"
            onChange={this.handleInputChange} />
        </label>
        <br />
        <label>
          Minutes to finish challenge:&nbsp;
          <input
            placeholder="0"
            name="minutes"
            type="number"
            min="0"
            onChange={this.handleInputChange} />
        </label>
        <input type="submit" value="Submit" />
      </form>
    );
  }
}

export default Form;
