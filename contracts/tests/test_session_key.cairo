use array::ArrayTrait;
use contracts::SessionKey;
use hash::LegacyHash;

const SESSION_TYPE_HASH: felt = 0x1aa0e1c56b45cf06a54534fa1707c54e520b842feb21d03b7deddb6f1e340c;

#[test]
#[available_gas(2000000)]
fn compute_hash() {

    let hash_state = LegacyHash::hash(0, 1);
    let hash_state = LegacyHash::hash(hash_state, 2);
    let hash_state = LegacyHash::hash(hash_state, 3);
    let hash1 = LegacyHash::hash(hash_state, 3);

    let mut elem = ArrayTrait::<felt>::new();
    elem.append(1);
    elem.append(2);
    elem.append(3);
    let secondHash = SessionKey::compute_hash(ref elem, 0_usize, 0);

    assert(hash1 == secondHash, 'invalid signature');
}