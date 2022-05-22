pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RDEVault is
    ERC721("RDE Vault", "RDE"),
    ERC721Enumerable,
    ERC721URIStorage
{

    using Counters for Counters.Counter;
    using SafeMath for uint256;

    struct RDE_NFT {
        string uri;
        string doi;
        address owner;
        uint256 score;
    }

    Counters.Counter NFTCounter;
    mapping(uint256 => RDE_NFT) public NFTs;
    address public owner;

    event mintItemEvent(string _doi, uint256 _index, address _minter, uint256 timestamp);




    constructor() {
        owner = msg.sender;
    }

    modifier _onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function mintItem(string memory _uri, string memory _doi)
        public
        returns (uint256)
    {
        uint256 currId = NFTCounter.current();
        NFTs[currId].uri = _uri;
        NFTs[currId].doi = _doi;
        NFTs[currId].owner = msg.sender;
        NFTs[currId].score = 0;

        _mint(msg.sender, currId);
        _setTokenURI(currId, _uri);

        NFTCounter.increment();

        emit mintItemEvent(_doi, currId, msg.sender, block.timestamp);

        return currId;
    }
    function getNFTs(uint256[] memory idxs) public view returns(RDE_NFT[] memory){

        RDE_NFT[] memory output = new RDE_NFT[](idxs.length);
        for(uint256 i = 0;i<idxs.length;i++){
            output[i] = NFTs[idxs[i]];
        }
        return output;
    }

    function getNFT(uint256 idx) external view returns (RDE_NFT memory){
        return NFTs[idx];
    }

    function increaseScore(uint256 idx, uint256 amount) external {
        NFTs[idx].score = NFTs[idx].score.add(amount);
    }

}
