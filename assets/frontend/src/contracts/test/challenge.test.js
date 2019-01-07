var Challenge = artifacts.require("./Challenge.sol");

contract('Challenge', function(accounts) {
  const owner = accounts[0];
  const initiator = accounts[1];
  const contender = accounts[2];

  it("initializes new data struct", async () => {
    const challenge = await Challenge.deployed();

    const desc = await challenge.getDescription();

    assert.equal(desc, "Walk 1 mile a day.", "description should match");
  });

  it("should not be expired on initial deployment", async () => {
    const challenge = await Challenge.deployed();

    const expired = await challenge.expired();

    assert.equal(expired, false, "should not be expired");
  });

  it("should be able to extend expiration", async () => {
    const challenge = await Challenge.deployed();

    var eventEmitted = false;
    tx = await challenge.extendExpiration(0, 0, 1, {from: owner});

    if (tx.logs[0].event === "ExtendExpiration") {
      eventEmitted = true;
    }

    const extended = await challenge.extended();

    assert.equal(extended, true, "should be true");
    assert.equal(eventEmitted, true, "should emit ExtendExpiration event");
  });

  it("should be extended only once", async () => {
    const challenge = await Challenge.deployed();

    try {
      await challenge.extendExpiration(0, 1, {from: owner});
    } catch(e) {
      assert(e, false, "should revert on further attempts");
    }
  });

  it("should return contract balance", async () => {
    const challenge = await Challenge.deployed();

    const balance = await challenge.challengeBalance();

    assert.equal(balance, 0, "should be initialy set to 0");
  });

  it("should be able to receive ether", async () => {
    const challenge = await Challenge.deployed();

    const deposit = web3.utils.toBN(1);
    await challenge.sendTransaction({from: initiator, value: deposit});
    const balance = await challenge.challengeBalance();

    assert.equal(balance, 1, "should not be 0");
  });

  it("should be able to complete challenge", async () => {
    const challenge = await Challenge.deployed();

    const contenderOldBalance = await web3.eth.getBalance(contender);

    eventEmitted = false
    tx = await challenge.complete({from: owner});
    if (tx.logs[0].event === "CompleteChallenge") {
      eventEmitted = true;
    }

    const contenderNewBalance = await web3.eth.getBalance(contender);

    assert.notEqual(contenderOldBalance, contenderNewBalance, "should not be the same");
    assert.equal(eventEmitted, true, "should emit CompleteChallenge event");
  });

  it("should be able to flush ether from completed challenge", async () => {
    const challenge = await Challenge.deployed();

    const deposit = web3.utils.toBN(2);

    await challenge.sendTransaction({from: initiator, value: deposit});

    const challengeOldBalance = await web3.eth.getBalance(challenge.address);

    var eventEmitted = false;
    tx = await challenge.flushBalance({from: owner});
    if (tx.logs[0].event === "FlushBalance") {
      eventEmitted = true;
    }

    const challengeNewBalance = await web3.eth.getBalance(challenge.address);

    assert.equal(challengeOldBalance, 2, "should be 2");
    assert.notEqual(challengeOldBalance, challengeNewBalance, "should not be the same");
    assert.equal(challengeNewBalance, 0, "should not be positive");
    assert.equal(eventEmitted, true, "should emit FlushBalance event");
  });

  it("should restrict state change on paused switch", async () => {
    const challenge = await Challenge.deployed();

    await challenge.switchPause();

    const deposit = web3.utils.toBN(2);
    await challenge.sendTransaction({from: initiator, value: deposit});
    const balance = await web3.eth.getBalance(challenge.address);

    try {
      await challenge.flushBalance({from: owner});
    } catch(e) {
      assert.equal(e, false, "should not flush balance");
    }

    assert.equal(balance, 2, "should still have 2 ethers");
  });
});
