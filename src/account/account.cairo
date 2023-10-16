#[starknet::contract]
mod Account {
    use core::starknet::SyscallResultTrait;
    use starknet::{ContractAddress, get_caller_address, get_tx_info, call_contract_syscall, VALIDATED};
    use gauss::account::iaccount::{IAccount, Call};
    use zeroable::Zeroable;
    use array::ArrayTrait;
    use box::BoxTrait;
    use ecdsa::check_ecdsa_signature;

    #[storage]
    struct Storage {
        _public_key: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252) {
        self._public_key.write(public_key);
    }

    impl ImplIAccountExternal of IAccount<ContractState> {
        fn __execute__(ref self: ContractState, mut calls: Array<Call>) -> Span<felt252> {
            assert(!get_caller_address().is_zero(), 'invalid caller');
            let tx_info = get_tx_info().unbox();
            assert(tx_info.version != 0, 'invalid tx version');
            assert(calls.len() == 1_u32, 'not support multicall');
            let Call{to, selector, calldata} = calls.pop_front().unwrap();
            call_contract_syscall(address: to, entry_point_selector: selector, calldata: calldata.span()).unwrap_syscall()
            
        }
        fn __validate__(ref self: ContractState, calls: Array<Call>) -> felt252 {
            let tx_info = get_tx_info().unbox();
            let signature: Span<felt252> = tx_info.signature;
            let message_hash: felt252 = tx_info.transaction_hash;
            assert(signature.len() == 2_u32, 'invalid signature length');
            assert(check_ecdsa_signature(
                message_hash: message_hash,
                public_key: self._public_key.read(),
                signature_r: *signature.at(0_u32),
                signature_s: *signature.at(1_u32)
            ), 'invalid signature');
            VALIDATED
        }

        fn is_valid_signature(ref self: ContractState, hash: felt252, signature: Array<felt252>) -> felt252 {
            assert(check_ecdsa_signature(
                message_hash: hash,
                public_key: self._public_key.read(),
                signature_r: *signature.at(0_u32),
                signature_s: *signature.at(1_u32)
            ), 'invalid signature');
            VALIDATED
        }
    }
}