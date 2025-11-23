// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract RentalAssetManager_MinimalUser {

    // --- 1. Ownership and Minimal ERC-721 Implementation ---

    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner.");
        _;
    }

    // State Variables for Minimal ERC-721
    string public name = "Decentralized Rental Asset";
    string public symbol = "DRA";
    mapping(uint256 => address) private _owners; // TokenId -> Owner Address
    mapping(address => uint256) private _balances; // Owner Address -> Token Count
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // ERC-721 Helper Functions
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }
    
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        require(_owners[tokenId] == from, "NFT: sender is not current owner.");
        
        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "NFT: cannot mint to the zero address.");
        require(!_exists(tokenId), "NFT: token already minted.");

        _balances[to]++;
        _owners[tokenId] = to;
        
        emit Transfer(address(0), to, tokenId);
    }

    // --- 2. Rental Contract Logic ---

    struct RentalRequest {
        address renter;
        uint256 tokenId;
        uint256 durationInDays;
        uint256 feePaid;
        bool approved;
    }

    mapping(uint256 => uint256) public nftPricePerDay; 
    RentalRequest[] public rentalRequests;
    mapping(uint256 => uint256) public rentalEndTime; 
    mapping(address => uint256) public rentedTokenByAddress; 
    
    uint256 public nextRequestId = 1;
    uint256 private constant NUM_INITIAL_NFTS = 15;
    
    uint256 private constant DEFAULT_DURATION_DAYS = 1;
    uint256 private constant DEFAULT_PRICE_PER_DAY_WEI = 6666666666666; 


    // --- 3. Constructor & Initial Setup ---

    constructor() {
        owner = msg.sender;
        _mintInitialNFTs();
    }
    
    function _mintInitialNFTs() internal {
        for (uint256 i = 1; i <= NUM_INITIAL_NFTS; i++) {
            _mint(address(this), i); 
            nftPricePerDay[i] = DEFAULT_PRICE_PER_DAY_WEI; 
        }
    }

    // --- HELPER FUNCTION: FIND AVAILABLE NFT ---
    
    function _findAvailableToken() internal view returns (uint256 availableTokenId) {
        for (uint256 i = 1; i <= NUM_INITIAL_NFTS; i++) {
            if (rentalEndTime[i] < block.timestamp) {
                return i;
            }
        }
        return 0;
    }

    // --- USER FUNCTION (Minimal Input) ---

    function requestRental() public payable {
        require(rentedTokenByAddress[msg.sender] == 0 || rentalEndTime[rentedTokenByAddress[msg.sender]] < block.timestamp, 
                "Manager: Wallet already has an active rental.");

        uint256 tokenIdToRent = _findAvailableToken();
        require(tokenIdToRent != 0, "Manager: No NFTs currently available for rent.");

        uint256 requiredFee = DEFAULT_PRICE_PER_DAY_WEI;
        require(msg.value == requiredFee, "Manager: Must send exactly the 1-day rental fee.");

        rentalRequests.push(RentalRequest(
            msg.sender, 
            tokenIdToRent, 
            DEFAULT_DURATION_DAYS, 
            msg.value, 
            false
        ));
        
        emit RentalRequested(nextRequestId, msg.sender, tokenIdToRent, DEFAULT_DURATION_DAYS);
        nextRequestId++;
    }

    // --- OWNER FUNCTIONS ---
    
    function setNFTPrice(uint256 _tokenId, uint256 _pricePerDayInWei) public onlyOwner {
        require(_exists(_tokenId), "Manager: NFT does not exist.");
        nftPricePerDay[_tokenId] = _pricePerDayInWei;
    }

    function withdrawAllFees() public onlyOwner {
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Manager: Withdrawal failed.");
    }
    
    function batchApproveRental(uint256[] calldata _requestIds) public onlyOwner {
        for (uint256 i = 0; i < _requestIds.length; i++) {
            uint256 reqId = _requestIds[i];
            
            require(reqId > 0 && reqId < nextRequestId, "Manager: Invalid Request ID.");
            RentalRequest storage req = rentalRequests[reqId - 1]; 
            
            require(!req.approved, "Manager: Request already approved.");
            require(rentalEndTime[req.tokenId] < block.timestamp, "Manager: NFT is currently rented.");

            require(rentedTokenByAddress[req.renter] == 0 || rentalEndTime[rentedTokenByAddress[req.renter]] < block.timestamp,
                    "Manager: Renter already active.");

            req.approved = true;

            _safeTransfer(address(this), req.renter, req.tokenId);

            uint256 expirationTime = block.timestamp + (req.durationInDays * 1 days);
            rentalEndTime[req.tokenId] = expirationTime;
            rentedTokenByAddress[req.renter] = req.tokenId; 
            
            emit RentalApproved(reqId, req.renter, req.tokenId);
        }
    }
    
    // --- Fallback, Receive, Events, and Views ---
    receive() external payable {}
    fallback() external payable {}

    event RentalRequested(uint256 indexed requestId, address indexed renter, uint256 tokenId, uint256 duration);
    event RentalApproved(uint256 indexed requestId, address indexed renter, uint256 tokenId);

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _owners[tokenId];
    }
}
