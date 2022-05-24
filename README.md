# Gasless-Airdrop
using EIP712 signature, meta transaction, and merkle tree

This is a useful technique when it comes to integrating NFT airdrop functionality into your web3 project.
`Airdrop.sol` can be used gaslessly with `EIP712MetaTransaction.sol` if project is using a relayer such as biconomy.

`Airdrop` contract does two things:
- permitted EOA can create a whitelist gasslessly via `createWhitelist()`
- whitelisted EOAs can mint also gasslessly via `mintWhitelist()`

In order to create a whitelist, your backend or script must first create a signature using EIP712 off-chain message signing.
You can test it with `npm run sig`, but use your own provider and two private keys in the script `generate_whitelist_sig.js`.

Then your backend should also create a merkle root using a list of EOAs to be added to whitelist.
You can test it with `npm run root`, but use your known EOAs in the script `whitelistAddresses.js`.

When above two arguments are ready, you can pass those values to `Airdrop` contract's `createWhitelist()`

Lastly, when whitelisted EOAs want to mint, your backend should first generate a merkle proof.
You can test it with `npm run proof`, and note that it's currently picking a random EOA from `whitelistAddresses.js`.

When merkle proof is ready, pass it to `mintWhitelist()` and whitelisted EOA will be able to mint!

Download or `git clone` the repo then `npm install`. 

I haven't added a deployment script for contracts, so feel free to deploy to remix or add a script yourself.
