
const Scolaire = artifacts.require("Scolaire.sol");

module.exports =async function(deployer, network, accounts)  {
    // deployer.deploy(Scolaire);
    //const accounts = await web3.eth.getAccounts();
    const initialOwner = accounts[0]; // Set the initial owner address here

    deployer.deploy(Scolaire, initialOwner);

}