// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Chagors is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 333;
    uint256 public mintPrice = 0.05 ether;       // example price — change or set to 0
    uint256 public maxPerTx = 5;                 // limit per transaction
    bool public saleActive = false;
    string private baseTokenURI;
    string private uriSuffix = ".json";

    event BaseURIChanged(string newBaseURI);
    event SaleStateChanged(bool active);
    event MintPriceChanged(uint256 newPrice);
    event MaxPerTxChanged(uint256 newMax);

    constructor(string memory initialBaseURI) ERC721("Chagors", "CHG") {
        baseTokenURI = initialBaseURI;
    }

    /* ------------------ Public mint ------------------ */
    function mint(uint256 quantity) external payable nonReentrant {
        require(saleActive, "Sale is not active");
        require(quantity > 0 && quantity <= maxPerTx, "Invalid quantity");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Exceeds max supply");
        require(msg.value >= mintPrice * quantity, "Insufficient ETH");

        uint256 startId = totalSupply() + 1;
        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(msg.sender, startId + i);
        }
    }

    /* ------------------ Owner functions ------------------ */
    // Owner can mint directly (for reserves, giveaways)
    function ownerMint(address to, uint256 quantity) external onlyOwner {
        require(quantity > 0, "Quantity must be > 0");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Exceeds max supply");
        uint256 startId = totalSupply() + 1;
        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(to, startId + i);
        }
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseTokenURI = newBaseURI;
        emit BaseURIChanged(newBaseURI);
    }

    function setUriSuffix(string calldata newSuffix) external onlyOwner {
        uriSuffix = newSuffix;
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
        emit MintPriceChanged(newPrice);
    }

    function setMaxPerTx(uint256 newMax) external onlyOwner {
        maxPerTx = newMax;
        emit MaxPerTxChanged(newMax);
    }

    function flipSaleState() external onlyOwner {
        saleActive = !saleActive;
        emit SaleStateChanged(saleActive);
    }

    // Withdraw contract balance to owner
    function withdraw() external onlyOwner nonReentrant {
        payable(owner()).transfer(address(this).balance);
    }

    /* ------------------ Metadata ------------------ */
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory base = _baseURI();
        return bytes(base).length > 0
            ? string(abi.encodePacked(base, tokenId.toString(), uriSuffix))
            : "";
    }

    /* ------------------ Misc ------------------ */
    // Prevent accidental renounce of ownership without consideration (optional)
    function renounceOwnership() public override onlyOwner {
        // If you want to allow renounceOwnership, remove this override
        revert("Renounce ownership is disabled");
    }

    // Fallback to accept ETH (if someone sends directly)
    receive() external payable {}
}
