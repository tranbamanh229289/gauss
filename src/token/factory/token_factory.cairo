use core::option::OptionTrait;
use starknet::ContractAddress;
use starknet::syscalls::deploy_syscall;

#[starknet::interface]
trait ITokenFactoryExternal<TContractState> {
    fn createToken(ref self: TContractState, name: felt252, symbol: felt252, decimals: u8, total_supply: u256);
}

#[starknet::contract]
mod token_factory {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::class_hash_try_from_felt252;
    use starknet::syscalls::deploy_syscall;

    use launchpad::token::erc20::erc20::ERC20;
    use launchpad::token::erc20::ierc20::IERC20Dispatcher;
    use launchpad::token::erc20::ierc20::IERC20DispatcherTrait;

    #[storage]
    struct Storage {
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CreatedToken: CreatedToken
    }

    #[derive(Drop, starknet::Event)]
    struct CreatedToken {
        owner: ContractAddress,
        token: ContractAddress
    }

    #[external(v0)]
    impl ImplTokenFactoryExternal of super::ITokenFactoryExternal<ContractState> {
        fn createToken(ref self: ContractState, name: felt252, symbol: felt252, decimals: u8, total_supply: u256) {
            let class_hash_erc20_felt: felt252 = 0x01fcc3390110d1eebe304af3f498185f1c41316d93cf73c026241cc7d3f1c602;
            let caller: ContractAddress = get_caller_address();
            let mut calldata = array![name, symbol, decimals.into(), caller];
            
            let (erc20_address, _) = deploy_syscall(class_hash_try_from_felt252(class_hash_erc20_felt).unwrap(), 0, calldata, false).unwrap();
            let mut token = IERC20Dispatcher{contract_address: erc20_address};
            token._mint(caller, total_supply);
            self.emit(CreatedToken{ owner: caller, token: caller});
        }
    }
}