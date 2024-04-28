

const ScolaireApplication = artifacts.require("ScolaireApplication.sol"); 
module.exports =async function(deployer, network, accounts)  {


    deployer.deploy(ScolaireApplication);
    
}
