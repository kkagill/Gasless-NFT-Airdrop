const { ethers } = require("ethers");

async function main() {
    const provider = ethers.getDefaultProvider(); // this is for testing, use your own provider

    const ownerPK = new ethers.Wallet.createRandom(); // this is for testing, use your pk instead
    const owner = new ethers.Wallet(ownerPK, provider);

    const whitelistCreatorPK = new ethers.Wallet.createRandom(); // this is for testing, use your pk instead
    const whitelistCreator = new ethers.Wallet(whitelistCreatorPK, provider);

    const domainSeparator = {
        chainId: 80001 // polygon testnet mumbai
    };
    
    const WhitelistInfo = [
        { name: 'contractAddress', type: 'address' },
        { name: 'creator', type: 'address' },
        { name: 'uniqueId', type: 'string' }
      ];

    const data = {
        contractAddress: '0x9200642CEf03011058D5143f26334d1e4d5F6576', // use deployed airdrop contract address
        creator: whitelistCreator.address,
        uniqueId: "627491157d9be2c2a234ecd2", // can be any value
    };
    const signature = await owner._signTypedData(domainSeparator, { WhitelistInfo }, data);
    
    console.log(signature)
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
