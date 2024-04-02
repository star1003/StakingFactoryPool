import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre , {upgrades} from "hardhat";

describe("Staking", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFactory() {
    // const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    // const ONE_GWEI = 1_000_000_000;

    // const lockedAmount = ONE_GWEI;
    // const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // // Contracts are deployed using the first signer/account by default
    // const [owner, otherAccount] = await hre.ethers.getSigners();

    // const Lock = await hre.ethers.getContractFactory("Lock");
    // const lock = await Lock.deploy(unlockTime, { value: lockedAmount });
    
    // return { lock, unlockTime, lockedAmount, owner, otherAccount };
    
    
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      // const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

      // expect(await lock.unlockTime()).to.equal(unlockTime);
      const [owner, otherAccount] = await hre.ethers.getSigners();
      const Mut = await hre.ethers.getContractFactory("MUT");
      const mut = await upgrades.deployProxy(Mut, ["MUT Token", "MUT", 1000n]);
      console.log('Mut address' , await mut.getAddress())
      const Factory = await hre.ethers.getContractFactory("StakingFactory");
      
      const beacon = await upgrades.deployBeacon(Factory)
      console.log('beacon' , await beacon.getAddress())
      const factory = await upgrades.deployBeaconProxy(beacon , Factory , [await beacon.getAddress(), 60n])
      console.log('factory' , await factory.getAddress())
      await factory.createStakingPool(await mut.getAddress())

      console.log('GetpoolAddr' , await factory.getPoolForRewardDistribution(await mut.getAddress()))
    });
  })

});
