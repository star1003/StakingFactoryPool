import hre, { ethers, upgrades, tenderly } from 'hardhat';
import { getImplementationAddressFromBeacon } from '@openzeppelin/upgrades-core';

async function main() {
    const [deployer] = await ethers.getSigners();


    const MUTFactory = await ethers.getContractFactory("MUT")
    const MUT = await upgrades.deployProxy(MUTFactory, ["MUT Token", "MUT", 1000n]);
    await MUT.waitForDeployment();
    console.log("MUT Address: ", await MUT.getAddress());

    const StakingFactory = await ethers.getContractFactory("StakingFactory");

    const beacon = await upgrades.deployBeacon(StakingFactory);
    await beacon.waitForDeployment();
    console.log("Beacon deployed to:", await beacon.getAddress());

    const factory = await upgrades.deployBeaconProxy(beacon, StakingFactory, [await beacon.getAddress(), 60n]);
    await factory.waitForDeployment();
    console.log("StakingFactory deployed to:", await factory.getAddress());

    await factory.createStakingPool(await MUT.getAddress())
    console.log("created pool address" , await factory.getPoolForRewardDistribution(await MUT.getAddress()))
    // await tenderly.verify({
    //     {
    //         name: 'StakingPool',
    //         address: await getImplementationAddressFromBeacon(ethers.provider, await beacon.getAddress()),
    //     },
    //     {
    //         name: 'UpgradeableBeacon',
    //         address: await beacon.getAddress(),
    //     },
    // })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

    // MUT Address:  0x40bB38Bb0a20dd8fb3Df32eE201a7F3D5751F6bf
    // Beacon deployed to: 0xE96a8dce970876190804DA994eCf0263FB4dd627
    // StakingFactory deployed to: 0xD44F9b57AAfEd5ac3140Bfc4b0fe15664afF6c19
//npx hardhat verify 0xD44F9b57AAfEd5ac3140Bfc4b0fe15664afF6c19 --network sepolia