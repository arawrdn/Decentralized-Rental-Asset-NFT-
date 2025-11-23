# Decentralized-Rental-Asset-NFT-
Decentralized Rental Asset (NFT), This smart contract manages a unique, non-custodial NFT rental system designed for operational efficiency. The contract supports a **Batch Approval** mechanism for the Owner and **Minimal Input** for the User, making asset management highly streamlined.

### Key Features:
* **Minimal User Input:** Users only initiate the rental by sending the fee (1-day) via the transaction's value (`msg.value`). No need to input Token ID or duration.
* **Batch Approval:** The Owner can review and approve multiple pending rental requests in a single blockchain transaction, significantly reducing gas costs and management time.
* **Static Crypto Price:** The daily rental fee is fixed in the contract at **6,666,666,666,666 Wei** (equivalent to 0.00001 ETH / 36 hours).

## 🔗 Contract Details

| Attribute | Detail |
| :--- | :--- |
| **Blockchain** | EVM Compatible Chain |
| **Solidity Version** | 0.8.30 |
| **Contract Address** | **`0xe8E86CFc428036165d19418FDC7B322Aac542699`** |
| **Owner's Primary Action** | `batchApproveRental(uint256[] _requestIds)` |
| **User's Primary Action** | `requestRental()` (Sends ETH value) |
