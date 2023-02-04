#[contract]
mod SessionKey {
    use array::ArrayTrait;
    use hash::LegacyHash;
    
    const ERC165_IERC165_INTERFACE_ID: felt = 0x01ffc9a7;
    const STARKNET_DOMAIN_TYPE_HASH: felt = 0x13cda234a04d66db62c06b8e3ad5f91bd0c67286c2c7519a826cf49da6ba478;
    const SESSION_TYPE_HASH: felt = 0x1aa0e1c56b45cf06a54534fa1707c54e520b842feb21d03b7deddb6f1e340c;
    const POLICY_TYPE_HASH: felt = 0x2f0026e78543f036f33e26a8f5891b88c58dc1e20cbbfaf0bb53274da6fa568;

    struct Storage {
        session_key_revoked_keys: felt
    }

    #[event]
    fn session_key_revoked(key: felt) {}

    #[external]
    fn revokeSessionKey(signer: felt) {
        session_key_revoked_keys::write(signer);
        // Todo emit event
    }

    // ERC165
    #[view]
    fn supportsInterface(interface_id: felt) -> bool {
        interface_id == ERC165_IERC165_INTERFACE_ID
    }

    // ERC1271
    #[view]
    fn isValidSignature(ref signatures: Array::<felt>, hash: felt) -> bool {
        // todo: wait for get_tx_info to be implemented
        // let tx_info = get_tx_info();
        
        // parse the plugin data
        let signature_r = signatures.at(1_usize);
        let signature_s = signatures.at(2_usize);
        let session_key = signatures.at(3_usize);
        let session_expires = signatures.at(4_usize);
        let root = signatures.at(5_usize);
        let proof_len = signatures.at(6_usize);
        let proofs_len = signatures.at(7_usize);
        let proofs = signatures.at(8_usize);
        let session_token_offset: usize = 8_usize + u64_from_felt(proofs_len);
        let session_token_len = signatures.at(session_token_offset);
        
        // todo: wait for get_block_timestamp to be implemented
        // assert(get_block_timestamp() >= session_expires, 'stark_signer: session expired');
        
        // hardcoded addr and chainId, waiting for get tx info
        let session_hash = compute_session_hash(
            session_key, session_expires, root, 1, 0x1234
        );  
        1 == 1
        // ecdsa::check_ecdsa_signature(hash, stark_signer_public_key::read(), signature_r, signature_s)
    }

    fn compute_session_hash(
        session_key: felt, session_expires: felt, root: felt, chain_id: felt, account: felt
    ) -> felt {
        let domain_hash = hash_domain(chain_id);
        let message_hash = hash_message(session_key, session_expires, root);

        let hash_state = LegacyHash::hash(0, 'StarkNet Message');

        let hash_state = LegacyHash::hash(hash_state, domain_hash);
        let hash_state = LegacyHash::hash(hash_state, account);
        let hash_state = LegacyHash::hash(hash_state, message_hash);
        LegacyHash::hash(hash_state, 4)
    }

    fn hash_domain(chain_id: felt) -> felt {
        let hash_state = LegacyHash::hash(0, STARKNET_DOMAIN_TYPE_HASH);
        let hash_state = LegacyHash::hash(hash_state, chain_id);
        LegacyHash::hash(hash_state, 2)
    }

    fn hash_message(session_key: felt, session_expires: felt, root: felt) -> felt {
        let hash_state = LegacyHash::hash(0, SESSION_TYPE_HASH);
        let hash_state = LegacyHash::hash(hash_state, session_key);
        let hash_state = LegacyHash::hash(hash_state, session_expires);
        let hash_state = LegacyHash::hash(hash_state, root);
        LegacyHash::hash(hash_state, 4)
    }
}
