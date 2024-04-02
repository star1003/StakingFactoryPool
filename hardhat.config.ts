import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';
import * as tdly from "@tenderly/hardhat-tenderly";
// import { TENDERLY_PRIVATE_VERIFICATION, TENDERLY_AUTOMATIC_VERIFICATION } from './secrets.json'
const accounts = ["7c5039a6450169b1f4d951abae17910c3e680a8ea3daaa3275d9745baea33957"];

// const privateVerification = TENDERLY_PRIVATE_VERIFICATION === true;

// const automaticVerifications = TENDERLY_AUTOMATIC_VERIFICATION === true;

// tdly.setup({ automaticVerifications });

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  etherscan: {
    apiKey: 'BRJ4NYMG97WDD1EUF4AEFHAVCF42B7KA47',
  },
  sourcify: {
    enabled: false,
  },
  networks: {
    sepolia: {
      url: "https://ethereum-sepolia-rpc.publicnode.com",
      accounts,
    },
    bscTestnet: {
      url: 'https://bsc-testnet-rpc.publicnode.com',
      accounts,
    },
    polygonMumbai: {
      url: 'https://polygon-mumbai-bor-rpc.publicnode.com',
      accounts,
    },
    // tenderly: {
    //   project: "project",
    //   username: "hetape",
    //   privateVerification,
    // },
  },
};

export default config;
