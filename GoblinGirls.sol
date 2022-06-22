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
    mapping(address => uint256) purchased;
    mapping(address => bool) goblinMinted;
    uint256 private freeMinted = 0;
    uint256 maxFree = 1000;

    uint256 public tokenPrice = 1 ether;
    bool public hasSaleStarted = false;

    IERC721A public goblinTown = IERC721A(0xbCe3781ae7Ca1a5e050Bd9C4c77369867eBc307e);

    constructor() ERC721A("Goblin Girls", "GG", 30, 100) {
    }


    function reserve(uint256 quantity) external onlyOwner {
        require(quantity + totalSupply() <= collectionSize, "GG: Not enough tokens left for minting");
        
        _safeMint(msg.sender, quantity);
    }

    function mint(uint256 quantity) external payable {
        require(msg.value >= tokenPrice * quantity, "GG: Incorrect ETH");
        require(hasSaleStarted, "GG: Cannot mint before sale has started");
        require(quantity + totalSupply() <= collectionSize, "GG: Total supply exceeded");
        require(purchased[msg.sender] + quantity <= 30, "GG: Can not purchase more than 30");

        purchased[msg.sender] += quantity;
        _safeMint(msg.sender, quantity);
    }

    function mintFree() external payable {
        require(hasSaleStarted, "GG: Cannot mint before sale has started");
        require(1 + totalSupply() <= collectionSize, "GG: Total supply exceeded");
        require(freeMinted++ < maxFree, "GG: No more free Goblin Girls available");
        if(goblinTown.balanceOf(msg.sender) > 0 && !goblinMinted[msg.sender]) {
            whitelisted[msg.sender] = true;
        }
        require(whitelisted[msg.sender] && !goblinMinted[msg.sender], "GG: User is not approved for free mint");

        goblinMinted[msg.sender] = true;
        whitelisted[msg.sender] = false;

        _safeMint(msg.sender, 1);
    }

    function addToWl(address[] calldata addresses) external onlyOwner{
        for(uint i=0; i<addresses.length; i++) {
            whitelisted[addresses[i]] = true;
        }
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

    function withdrawAll() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}
