const Challenge = artifacts.require("./Challenge");

module.exports = function(deployer, _, accounts) {
  const challenger = accounts[1];
  const contender = accounts[2];
  const days = 0;
  const hours = 0;
  const minutes = 1;
  const description = "Walk 1 mile a day.";
  deployer.deploy(Challenge, challenger, contender, days, hours, minutes, description);
}
