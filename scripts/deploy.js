const { ethers } = require("hardhat");

async function main() {
    const KalEl = await ethers.getContractFactory("KalElToken");
    const token = await KalEl.deploy(1000, "KAL-EL Token", "KET", 10000, 18);
    await token.waitForDeployment();

    console.log("Token deployed successfully to : ", await token.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });