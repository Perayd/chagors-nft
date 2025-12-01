const { ethers } = require("hardhat");

async function main() {
  const baseURI = "https://your-metadata-host.com/metadata/";
  const Chagors = await ethers.getContractFactory("Chagors");
  const chagors = await Chagors.deploy(baseURI);
  await chagors.deployed();
  console.log("Chagors deployed to:", chagors.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
