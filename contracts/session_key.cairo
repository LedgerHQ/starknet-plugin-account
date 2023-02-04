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

    struct CallArray {
        to: felt,
        selector: felt,
        data_offset: felt,
        data_len: felt,
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
    fn validate(ref signatures: Array::<felt>, hash: felt) -> bool {
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
        // assert(get_block_timestamp() >= session_expires, 'session_key: session expired');
        assert(session_key_revoked_keys::read() == 0, 'session_key: session key revoked');

        // hardcoded addr and chainId, waiting for get tx info
        let session_hash = compute_session_hash(
            session_key, session_expires, root, 1, 0x1234
        );  
        // call IAccount.isValidSignature
        
        // todo: wait for get_transaction_hash to be implemented
        // ecdsa::check_ecdsa_signature(
        //     tx.transaction_hash, 
        //     session_key, 
        //     signature_r, 
        //     signature_s
        // );

        // check_policy(call_array_len, call_array, root, proof_len, proofs_len, proofs);
        0 == 0

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
        let mut elem = ArrayTrait::<felt>::new();
        elem.append(STARKNET_DOMAIN_TYPE_HASH);
        elem.append(chain_id);
        compute_hash(ref elem, 0_usize, 0)
    }

    fn hash_message(session_key: felt, session_expires: felt, root: felt) -> felt {
        let mut elem = ArrayTrait::<felt>::new();
        elem.append(SESSION_TYPE_HASH);
        elem.append(session_key);
        elem.append(session_expires);
        elem.append(root);
        compute_hash(ref elem, 0_usize, 0)
    }

    fn check_policy(ref call_array: Array::<CallArray>, root: felt, proof_len: felt, proofs: Array::<felt>) -> bool {
        if call_array.len() == 0_usize {
            return true;
        }
        let hash_state = LegacyHash::hash(0, POLICY_TYPE_HASH);
        let hash_state = LegacyHash::hash(hash_state, call_array.at(0_usize).to);
        let hash_state = LegacyHash::hash(hash_state, call_array.at(0_usize).selector);
        let leaf = LegacyHash::hash(hash_state, 3);
        true
    }

    fn compute_hash(ref elem: Array::<felt>, elem_index: u64, hash: felt) -> felt {
        match get_gas_all(get_builtin_costs()) {
            Option::Some(_) => {},
            Option::None(_) => {
                let mut data = ArrayTrait::new();
                data.append('OOG');
                panic(data);
            }
        }
        if elem.len() == elem_index {
            return LegacyHash::hash(hash, u64_to_felt(elem.len()));
        }
        let elem_to_hash = elem.at(elem_index);
        let hash_state = LegacyHash::hash(hash, elem_to_hash);
        compute_hash(ref elem, elem_index + 1_usize, hash_state)
    }

    // This plugin can only validate call
    #[view]
    fn isValidSignature(ref signatures: Array::<felt>, hash: felt) -> bool {
        false
    }
}
