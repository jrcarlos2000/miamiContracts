pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {IRDEVault} from "./IRDEVault.sol";

contract ProposalVault {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    event proposalMade(
        string doi,
        address proposer,
        uint256 idx,
        uint256 deadline
    );

    address public Owner;
    address public Vault;

    constructor(address _Vault) public {
        Owner = msg.sender;
        Vault = _Vault;
    }

    struct proposal {
        string doi;
        uint256 amount;
        address proposer;
        uint256 deadline;
    }

    Counters.Counter proposalCount;
    mapping(uint256 => proposal) public proposals;

    function propose(string memory _doi, uint256 allowedTime) external payable {
        require(msg.value > 0, " Amount to fund should be greater than 0");
        uint256 currIdx = proposalCount.current();
        proposals[currIdx].doi = _doi;
        proposals[currIdx].amount = msg.value;
        proposals[currIdx].proposer = msg.sender;
        uint256 deadline = allowedTime.add(block.timestamp);
        proposals[currIdx].deadline = deadline;
        proposalCount.increment();
        emit proposalMade(_doi, msg.sender, currIdx, deadline);
    }

    function getProposals(uint256[] memory idxs)
        external
        view
        returns (proposal[] memory)
    {
        proposal[] memory output = new proposal[](idxs.length);

        for (uint256 i = 0; i < idxs.length; i++) {
            output[i] = proposals[idxs[i]];
        }
        return output;
    }

    function vote(uint256 nft_idx, uint256 proposal_idx) external {
        address proposer = proposals[proposal_idx].proposer;
        uint256 amount = proposals[proposal_idx].amount;
        string memory _doi = proposals[proposal_idx].doi;
        require(proposer == msg.sender, "Caller is not the proposer");
        IRDEVault.RDE_NFT memory currNFT = IRDEVault(Vault).getNFT(nft_idx);
        if (
            keccak256(abi.encodePacked(currNFT.doi)) !=
            keccak256(abi.encodePacked(_doi))
        ) {
            revert();
        } else {
            IRDEVault(Vault).increaseScore(nft_idx, amount);
        }
    }
}
