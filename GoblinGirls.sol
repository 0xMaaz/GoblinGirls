// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";
import "./IERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GG is Ownable, ERC721A, ReentrancyGuard {
    string _baseUri = "ipfs://Qmd4pK5w6jZmNmKwbXjBfud7Lm7zvckm8AcGanFGJHL5gM/";
    mapping(address => bool) whitelisted;
    mapping(address => uint256) public purchased;
    mapping(address => bool) freeMinted;
    uint256 maxFree;

    uint256 public tokenPrice;
    bool public hasSaleStarted = false;

    IERC721A public goblinTown = IERC721A(0xbCe3781ae7Ca1a5e050Bd9C4c77369867eBc307e);

    constructor() ERC721A("Goblin Girls", "GG", 30, 10000) {
        maxFree = 2;
        tokenPrice = 0.01 ether;
    }


    function reserve(address to, uint256 quantity) external onlyOwner {
        require(quantity + totalSupply() <= collectionSize, "GG: Not enough tokens left for minting");
        _safeMint(to, quantity);
    }

    function mint(uint256 quantity) external payable {
        require(hasSaleStarted, "GG: Cannot mint before sale has started");
        require(quantity + totalSupply() <= collectionSize, "GG: Total supply exceeded");
        require(purchased[msg.sender] + quantity <= 30, "GG: Can not purchase more than 30");

        if(purchased[msg.sender] >= 2) require(msg.value >= tokenPrice * quantity, "GG: Incorrect ETH");
        else {
            if(quantity > maxFree) {
                uint256 memory amountPaid = quantity - maxFree;
                require(msg.value >= tokenPrice * amountPaid,"GG: Incorrect ETH");
            }
        }
        purchased[msg.sender] += quantity;
        _safeMint(msg.sender, quantity);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseUri = newBaseURI;
    }

    function flipSaleState() external onlyOwner {
        hasSaleStarted = !hasSaleStarted;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        tokenPrice = newPrice;
    }

    function setMaxFree(uint256 newMax) external onlyOwner {
        maxFree = newMax;
    }

    function withdrawAll() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}
