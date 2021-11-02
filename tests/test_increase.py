from brownie import reverts

def test_increase(tokenProcessor, ibBTC, deployer, keeper):
    initial_ppfs = ibBTC.pricePerShare()

    print(f"initial_ppfs={initial_ppfs}")

    with reverts("Not Keeper!"):
        tokenProcessor.increasePpfs(0)

    tx = tokenProcessor.increasePpfs(0, {"from": keeper})

    after_ppfs = ibBTC.pricePerShare()

    print(f"after_ppfs={after_ppfs}")

    assert after_ppfs > initial_ppfs

    # print event - inspect
    print(f"{tx.events['Injected']}")
