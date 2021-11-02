import pytest

WBTC_ADDR = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"
bcrvRenBTC_ADDR = "0x6dEf55d2e18486B9dDfaA075bc4e4EE0B28c1545"
bcrvSBTC_ADDR = "0xd04c48A53c111300aD41190D63681ed3dAd998eC"
bcrvTBTC_ADDR = "0xb9D076fDe463dbc9f915E5392F807315Bf940334"


@pytest.fixture(scope="module")
def deployer(accounts):
    yield accounts.at("0xDA25ee226E534d868f0Dd8a459536b03fEE9079b", force=True)


@pytest.fixture(scope="module")
def wbtc_whale(accounts):
    yield accounts.at("0x070f5A78963a658d3b8700BAF8e3C08984514eA2", force=True)


@pytest.fixture(scope="module")
def governance(accounts):
    yield accounts.at("0xB65cef03b9B89f99517643226d76e286ee999e77", force=True)


@pytest.fixture(scope="module")
def wbtc(interface):
    yield interface.ERC20(WBTC_ADDR)


@pytest.fixture(scope="module")
def ibBTC(interface):
    yield interface.IibBTC("0xc4E15973E6fF2A35cC804c2CF9D2a1b817a8b40F")


@pytest.fixture(scope="module")
def bcrvRenBTC(interface):
    yield interface.ISettV4(bcrvRenBTC_ADDR)


@pytest.fixture(scope="module")
def bcrvSBTC(interface):
    yield interface.ISettV4(bcrvSBTC_ADDR)


@pytest.fixture(scope="module")
def bcrvTBTC(interface):
    yield interface.ISettV4(bcrvTBTC_ADDR)


@pytest.fixture(scope="module")
def tokenProcessor(
    TokenProcessor,
    bcrvRenBTC,
    bcrvSBTC,
    bcrvTBTC,
    deployer,
    wbtc,
    wbtc_whale,
    governance,
):
    processor = deployer.deploy(TokenProcessor)

    # send some for testing
    amount_sent = 1 * 10 ** 8
    wbtc.transfer(processor.address, amount_sent, {"from": wbtc_whale})

    # approve this contract for deposits
    bcrvRenBTC.approveContractAccess(processor.address, {"from": governance})
    bcrvSBTC.approveContractAccess(processor.address, {"from": governance})
    bcrvTBTC.approveContractAccess(processor.address, {"from": governance})

    yield processor
