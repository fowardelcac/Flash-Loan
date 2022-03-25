from brownie import Flash, interface, config, accounts, network

amount = 3000000000000000000


def set():
    pool = config['networks'][network.show_active()]['PoolAddressesProvider']
    weth = interface.IERC20(config['networks']['kovan']['Weth'])
    cta = accounts.add(config['wallets']['from_key'])
    contrato = Flash.deploy(pool, {'from': cta})
    print("Contract deployed.")

    tx = weth.transfer(contrato.address, amount, {'from': cta})
    tx.wait(1)
    print("Tx finished, contract balance:", weth.balanceOf(contrato.address))
    return pool, weth, cta, contrato


def main():
    pool, weth, cta, contrato = set()
    #weth.approve(contrato.address, amount, {'from': cta})
    #print("Approve ready motherfuckerrr")
    print("*" * 100)
    try:
        flash = contrato.flashBorrow(
            weth, 2800000000000000000, {'from': cta, 'gas_limit': 2080000})
        flash.wait(1)
        print(flash.info())
        print("weth balance:", weth.balanceOf(contrato.address))
        retiro = contrato.withdraw(weth)
        retiro.wait(1)
        print(retiro.events)
    except:
        print("It doesn't work")
        tx = contrato.withdraw(weth, {'from': cta})
        print(tx.events)
