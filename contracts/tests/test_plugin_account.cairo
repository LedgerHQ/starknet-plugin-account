use contracts::PluginAccount;

const ERC165_INVALID_INTERFACE_ID: felt = 0xffffffff;

#[test]
#[available_gas(2000000)]
fn erc165_unsupported_interfaces() {
    assert(PluginAccount::supportsInterface(0) == false, 'value should be false');
    assert(!PluginAccount::supportsInterface(ERC165_INVALID_INTERFACE_ID), 'value should be false');
}

#[test]
#[available_gas(2000000)]
fn erc165_supported_interfaces() {
    let value = PluginAccount::supportsInterface(PluginAccount::ERC165_IERC165_INTERFACE_ID);
    assert(value, 'value should be true');
    let value = PluginAccount::supportsInterface(PluginAccount::ERC165_ACCOUNT_INTERFACE_ID);
    assert(value == true, 'value should be true');
    let value = PluginAccount::supportsInterface(PluginAccount::ERC165_OLD_ACCOUNT_INTERFACE_ID);
    assert(value, 'value should be true');
}