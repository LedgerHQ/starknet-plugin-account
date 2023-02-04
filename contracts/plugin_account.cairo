#[contract]
mod PluginAccount {
    use array::ArrayTrait;

    const ERC165_IERC165_INTERFACE_ID: felt = 0x01ffc9a7;
    const ERC165_ACCOUNT_INTERFACE_ID: felt = 0xa66bd575;
    const ERC165_OLD_ACCOUNT_INTERFACE_ID: felt = 0x3943f10f;

    struct Storage {
        plugins: LegacyMap::<felt, felt>,
        initialized: felt
    }

    #[event]
    fn AccountCreated(account: felt, plugin: felt) {}

    #[event]
    fn TransactionExecuted(hash: felt, response: Array::<felt>) {}

    #[external]
    fn initialize(plugin: felt, ref plugin_calldata: Array::<felt>) {
        // check that we are not already initialized
        assert(initialized::read() == 0, 'plugin_account: already initialized');
        // check that the target signer is not zero
        assert(plugin != 0, 'plugin_account: plugin cannot be null');
        // initialize the account
        initialize_plugin(plugin, ref plugin_calldata);

        plugins::write(plugin, 1);
        initialized::write(1);
    }

    fn initialize_plugin(plugin: felt, ref plugin_calldata: Array::<felt>) {
        if (plugin_calldata.len() == 0_usize) {
            return ();
        }

        // wait for delegate call
    }

    fn get_plugin_from_signature(ref signature: Array::<felt>) -> felt {

        assert(signature.len() != 0_usize, 'plugin_account: invalid signature len');

        let plugin = signature.at(0_usize);

        let is_plugin = plugins::read(plugin);
        assert(is_plugin != 0, 'plugin_account: unregistered plugin');
       
        plugin
    }

    // ERC165
    #[view]
    fn supportsInterface(interface_id: felt) -> bool {
        interface_id == ERC165_IERC165_INTERFACE_ID | interface_id == ERC165_ACCOUNT_INTERFACE_ID | interface_id == ERC165_OLD_ACCOUNT_INTERFACE_ID
    }

    // ERC1271
    #[view]
    fn isValidSignature(ref signatures: Array::<felt>, hash: felt) -> bool {
        // wait for delegate call
        1 == 1
    }
}
