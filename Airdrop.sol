// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./EIP712MetaTransaction.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/utils/cryptography/MerkleProof.sol";
import {ECDSA} from 'openzeppelin-solidity/contracts/utils/cryptography/ECDSA.sol';

contract Airdrop is EIP712MetaTransaction, ReentrancyGuard {   
    using ECDSA for bytes32;
 
    address public owner;
    IERC721 public myNftContract;

    // The whitelist typehash (used for checking signature validity)
    bytes32 private constant WHITELIST_TYPEHASH =
            keccak256('WhitelistInfo(address contractAddress,address creator,string uniqueId)');
    bytes32 private immutable DOMAIN_SEPARATOR;
    
    mapping(string => bytes32) public uniqueIdMerkleRoots;
    mapping(string => mapping(address => bool)) public whitelistClaimed;

    // Events
    event CreateWhitelist(
        address indexed _creator, 
        string _uniqueId, 
        uint256 _timestamp
    );
    event MintWhitelist(       
        address indexed _minter,
        string _uniqueId,
        uint256 _timestamp
    );

    constructor(address _nftAddress) EIP712Base(DOMAIN_NAME, DOMAIN_VERSION) {
        owner = msg.sender;
        myNftContract = IERC721(_nftAddress);
        DOMAIN_SEPARATOR = keccak256(abi.encode(keccak256('EIP712Domain(uint256 chainId)'), block.chainid));
    }

    function createWhitelist(
      string memory _uniqueId, 
      bytes32 _merkleRoot,
      bytes calldata _signature
    )
      external
    {
        require(bytes(_uniqueId).length > 0, "Airdrop#createWhitelist: _uniqueId is empty");
        require(bytes32(_merkleRoot).length > 0, "Airdrop#createWhitelist: _merkleRoot is empty");      
        require(
            uniqueIdMerkleRoots[_uniqueId] == 0,
            "Airdrop#createWhitelist: uniqueId has already been created"
        );
        address creator = msgSender();
        // check that the signature is valid 
        // which was signed with contract's owner's private key from backend.
        require(
            getSigner(_signature, creator, _uniqueId) == owner, 
            'Airdrop#createWhitelist: Invalid signer'
        );
        
        uniqueIdMerkleRoots[_uniqueId] = _merkleRoot;

        emit CreateWhitelist(
            creator, 
            _uniqueId, 
            block.timestamp
        );
    }

    function mintWhitelist(string memory _uniqueId, bytes32[] calldata _merkleProof) external nonReentrant {
        address minter = msgSender();
        require(uniqueIdMerkleRoots[_uniqueId] != "", "Airdrop#mintWhitelist: whitelist not created");
        require(!whitelistClaimed[_uniqueId][minter], "Airdrop#mintWhitelist: address already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(minter));
        bytes32 merkleRoot = uniqueIdMerkleRoots[_uniqueId];

        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Airdrop#mintWhitelist: invalid Merkle Proof");       
        whitelistClaimed[_uniqueId][minter] = true;
        
        // now call your erc721 contract that allows minting from an external contract
        // i.e. myNftContract.mintFromAirdrop(...);
        // or all functions in this airdrop contract can be added to your erc721 contract instead

        emit MintWhitelist(
            minter,
            _uniqueId,
            block.timestamp
        );          
    }

   function getSigner(
        bytes calldata _signature,
        address _creator, 
        string memory _uniqueId
    ) private view returns (address) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    WHITELIST_TYPEHASH, 
                    address(this), 
                    _creator, 
                    keccak256(abi.encodePacked(_uniqueId)) // convert string to bytes32                     
                ))
            )
        );

        address recoveredAddress = digest.recover(_signature);
        return recoveredAddress;
    }
}