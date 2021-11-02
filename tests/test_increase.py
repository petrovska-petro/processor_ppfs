def test_increase(tokenProcessor, ibBTC, deployer):
    initial_ppfs = ibBTC.pricePerShare()

    tx = tokenProcessor.increasePpfs()

    after_ppfs = ibBTC.pricePerShare()

    assert after_ppfs > initial_ppfs

    # print event - inspect
    print(f"{tx.events['Injected']}")
