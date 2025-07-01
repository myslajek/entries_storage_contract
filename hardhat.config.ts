import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.30",
     networks: {
    sonic: {
      url: "https://rpc.soniclabs.com",
      chainId: 146,
      accounts: [process.env.SONIC_PRIVATE_KEY!]
    },
    sonicTestnet: {
      url: "https://rpc.blaze.soniclabs.com",
      chainId: 57054,
      accounts: [process.env.SONIC_PRIVATE_KEY!]
    }
  },   
  etherscan: {
    apiKey: {
      sonic: process.env.SONIC_API_KEY!,
      sonicTestnet:  process.env.SONIC_API_KEY! 
    },
    customChains: [
      {
        network: "sonic",
        chainId: 146,
        urls: {
          apiURL: "https://api.sonicscan.org/api",
          browserURL: "https://sonicscan.org"
        }
      },
      {
        network: "sonicTestnet",
        chainId: 57054,
        urls: {
          apiURL: "https://api-testnet.sonicscan.org/api",
          browserURL: "https://testnet.sonicscan.org"
        }
      }
    ]
  }
};

export default config;
