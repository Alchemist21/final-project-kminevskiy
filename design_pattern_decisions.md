### Design patterns

* Circuit breaker: the contract implements this pattern to reduce potential damage in case bugs in code are discovered.
* Ownership (authorization pattern): only the owner (and authorized accounts) of the contract can execute critical functions
* Guard check: the changes to the state of the contract can be submitted only after passing specific requirements
* Secure ether transfer: utilize `transfer` method (reverts in case of any errors)
