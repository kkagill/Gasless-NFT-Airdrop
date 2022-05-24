const keccak256 = require('keccak256');
const { MerkleTree } = require('merkletreejs');
const { whitelistAddresses } = require('./whitelistAddresses');

const leafNodes = whitelistAddresses.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true});
const randomEOAFromArray = whitelistAddresses[Math.floor(Math.random()*whitelistAddresses.length)];
const claimingAddress = keccak256(randomEOAFromArray);
const hexProof = merkleTree.getHexProof(claimingAddress);
const doubleQuotedProof = JSON.stringify(hexProof);

console.log(doubleQuotedProof);