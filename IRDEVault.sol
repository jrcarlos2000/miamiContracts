pragma solidity ^0.8.0;

interface IRDEVault {
    struct RDE_NFT {
        string uri;
        string doi;
        address owner;
        uint256 score;
    }

    function getNFT(uint256 idx) external view returns (RDE_NFT memory);
    function increaseScore(uint256 idx, uint256 amount) external;
}