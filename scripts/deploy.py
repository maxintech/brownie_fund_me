from brownie import FundMe, network, config, MockV3Aggregator
from scripts.helpful_scripts import (
    deploy_mocks,
    get_account,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)


def deploy_fundme():
    account = get_account()
    # Pass the priceFeed address to FundMe
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed_address"
        ]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    verify = config["networks"][network.show_active()]["verify"]
    fundme = FundMe.deploy(price_feed_address, {"from": account}, publish_source=verify)
    print(f"Contract deployed to {fundme}")
    return fundme


def main():
    deploy_fundme()
