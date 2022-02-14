module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    const verifier = await deploy('Verifier', {
        from: deployer,
        log: true
    });

    await deploy('zkPhoto', {
        from: deployer,
        log: true,
        args: [verifier.address]
    });
};
module.exports.tags = ['complete'];
