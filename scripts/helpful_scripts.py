from brownie import network, accounts, config, MockV3Aggregator
from web3 import Web3

DECIMALS = 8
STARTING_PRICE = 200000000000  # Web3.toWei(2000, "ether")
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork"]


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        # uses the first fake account from Ganache server
        return accounts[0]
        # It's possible to save a private key for a wallet in brownie
        # $ brownie accounts add some-name
        # Then access it in the code
        # return accounts.load("some-name")
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"The acitve network is {network.show_active()}")
    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})
        print("Mock deployed")
