#[contract]
mod StarkSigner {
    use array::ArrayTrait;

    const ERC165_IERC165_INTERFACE_ID: felt = 0x01ffc9a7;

    struct Storage {
        stark_signer_public_key: felt
    }

    #[external]
    fn initialize(signer: felt) {
        // check that we are not already initialized
        assert(stark_signer_public_key::read() == 0, 'stark_signer: already initialized');
        assert(signer != 0, 'stark_signer: public key can not be zero');

        stark_signer_public_key::write(signer);
    }

    #[external]
    fn set_public_key(signer: felt) {
        // check that we are not already initialized
        assert(signer != 0, 'stark_signer: public key can not be zero');
        stark_signer_public_key::write(signer);
    }

    #[view]
    fn get_public_key() -> felt {
        stark_signer_public_key::read()
    }

    // ERC165
    #[view]
    fn supportsInterface(interface_id: felt) -> bool {
        interface_id == ERC165_IERC165_INTERFACE_ID
    }

    // ERC1271
    #[view]
    fn isValidSignature(ref signatures: Array::<felt>, hash: felt) -> bool {
        assert(signatures.len() >= 2_usize, 'stark_signer: signature format invalid');
        let signature_r = signatures.at(0_usize);
        let signature_s = signatures.at(1_usize);
        ecdsa::check_ecdsa_signature(hash, stark_signer_public_key::read(), signature_r, signature_s)
    }
}
