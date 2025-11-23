import { EthersAdapter } from '@reown/appkit-adapter-ethers5';
import { ethers } from 'ethers'; 

// Contract Address and ABI (Designed based on RentalAssetManager)
const CONTRACT_ADDRESS = '0xe8E86CFc428036165d19418FDC7B322Aac542699'; 

const RENTAL_CONTRACT_ABI = [
  // User Function: requestRental() - Payable
  { "inputs": [], "name": "requestRental", "outputs": [], "stateMutability": "payable", "type": "function" },
  // Owner Function: batchApproveRental(uint256[] _requestIds) - Nonpayable
  { "inputs": [{"internalType": "uint256[]", "name": "_requestIds", "type": "uint256[]"}], "name": "batchApproveRental", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
  // Owner Function: withdrawAllFees() - Nonpayable
  { "inputs": [], "name": "withdrawAllFees", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
  // View Function: ownerOf(uint256 tokenId) - View
  { "inputs": [{"internalType": "uint256", "name": "tokenId", "type": "uint256"}], "name": "ownerOf", "outputs": [{"internalType": "address", "name": "", "type": "address"}], "stateMutability": "view", "type": "function" }
];

// 1. Base Network Definition
const BASE_MAINNET_ID = 8453;
const BASE_RPC_URL = 'https://mainnet.base.org/'; 

// 2. WalletConnect Project ID (REMOVED FROM CONTEXT, USE STORED VALUE)
const WALLETCONNECT_PROJECT_ID = 'a5f9260bc9bca570190d3b01f477fc45'; 

// --- AppKit Initialization ---

export const appKit = new AppKit({
  metadata: {
    name: 'Decentralized Rental Asset DApp',
    description: 'NFT Rental Manager on Base Network.',
    url: 'https://your-dapp-domain.com',
    icons: [], 
  },
  adapter: new EthersAdapter(ethers),
  rpc: {
    [BASE_MAINNET_ID]: BASE_RPC_URL, 
  },
  connectors: {
    walletConnect: { projectId: WALLETCONNECT_PROJECT_ID },
  },
  defaultChainId: BASE_MAINNET_ID, 
});

// Example function to call the contract
export async function handleRequestRental() {
  const signer = appKit.signer;
  if (!signer) return;

  const RENTAL_FEE_WEI = ethers.BigNumber.from('6666666666666'); // 6.666 Trillion Wei
  
  try {
    const contract = new ethers.Contract(CONTRACT_ADDRESS, RENTAL_CONTRACT_ABI, signer);
    const tx = await contract.requestRental({ value: RENTAL_FEE_WEI });
    await tx.wait();
    console.log('Rental request successful:', tx.hash);
  } catch (error) {
    console.error('Transaction failed:', error);
  }
}
