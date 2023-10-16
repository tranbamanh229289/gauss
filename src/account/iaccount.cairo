use starknet::ContractAddress;
use array::ArrayTrait;

#[derive(Serde, Drop)]
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

#[starknet::interface]
trait IAccount <TContractState>{
    fn __execute__(ref self: TContractState, calls: Array<Call>) -> Span<felt252>;
    fn __validate__(ref self: TContractState,calls: Array<Call>) -> felt252;
    fn is_valid_signature(ref self: TContractState, hash: felt252, signature: Array<felt252>) -> felt252;
}