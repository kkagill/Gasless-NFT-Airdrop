const keccak256 = require('keccak256');
const { MerkleTree } = require('merkletreejs');
const { whitelistAddresses } = require('./whitelistAddresses');

const leafNodes = whitelistAddresses.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true});
const rootHash = merkleTree.getRoot();
const merkleRoot = "0x" + rootHash.toString('hex');

console.log(merkleRoot);