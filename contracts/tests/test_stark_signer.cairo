use array::ArrayTrait;
use contracts::StarkSigner;

const message_hash: felt = 0x2d6479c0758efbb5aa07d35ed5454d728637fceab7ba544d3ea95403a5630a8;

const signer_pubkey: felt = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
const signer_r: felt = 0x6ff7b413a8457ef90f326b5280600a4473fef49b5b1dcdfcd7f42ca7aa59c69;
const signer_s: felt = 0x23a9747ed71abc5cb956c0df44ee8638b65b3e9407deade65de62247b8fd77;

fn single_signature(r: felt, s: felt) -> Array::<felt> {
    let mut signatures = ArrayTrait::new();
    signatures.append(r);
    signatures.append(s);
    signatures
}

#[test]
#[available_gas(2000000)]
fn valid() {
    StarkSigner::initialize(signer_pubkey);
    let mut signatures = single_signature(signer_r, signer_s);
    assert(StarkSigner::isValidSignature(ref signatures, message_hash), 'invalid signature');
}

#[test]
#[available_gas(2000000)]
fn invalid_hash() {
    StarkSigner::initialize(signer_pubkey);
    let mut signatures = single_signature(signer_r, signer_s);
    assert(!StarkSigner::isValidSignature(ref signatures, 0), 'invalid signature');
    assert(!StarkSigner::isValidSignature(ref signatures, 123), 'invalid signature');
}

#[test]
#[available_gas(2000000)]
fn invalid_signer() {
    StarkSigner::initialize(signer_pubkey);
    let mut signatures = single_signature(0, 0);
    assert(!StarkSigner::isValidSignature(ref signatures, message_hash), 'invalid signature');
    let mut signatures = single_signature(42, 99);
    assert(!StarkSigner::isValidSignature(ref signatures, message_hash), 'invalid signature');
}

#[test]
#[available_gas(2000000)]
#[should_panic]
fn invalid_signature_length() {
    StarkSigner::initialize(signer_pubkey);
    let mut signatures = ArrayTrait::new();
    assert(!StarkSigner::isValidSignature(ref signatures, message_hash), 'invalid signature');
}