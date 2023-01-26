const { run } = require("hardhat");

async function verify(contractAddress, args) {
  console.log("Verifying");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Contract Already Verified");
    } else {
      console.error(e);
    }
  }
}

module.exports = { verify };
