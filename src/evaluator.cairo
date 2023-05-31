// ######## Messaging bridge evaluator

#[contract]
#[derive(Copy, Drop)]
mod Evaluator{

    ////////////////////////////////
    // Core Library Imports
    ////////////////////////////////
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::ContractAddress;
    use starknet::syscalls::send_message_to_l1_syscall;
    use array::ArrayTrait;
    use option::OptionTrait;
    use zeroable::Zeroable;
    use traits::TryInto;
    use traits::Into;
    use integer::u256;
    use integer::u256_from_felt252;


    ////////////////////////////////
    // Internal Imports
    ////////////////////////////////
    use starknet_messaging_bridge::utils::ex00_base::Ex00Base::distribute_points;
    use starknet_messaging_bridge::utils::ex00_base::Ex00Base::validate_exercise;
    use starknet_messaging_bridge::utils::ex00_base::Ex00Base::ex_initializer;
    use starknet_messaging_bridge::utils::ex00_base::Ex00Base::update_class_hash_by_admin;
    use starknet_messaging_bridge::utils::helper;


    ////////////////////////////////
    // Storage
    ////////////////////////////////
    struct Storage{
        l1_evaluator_address: felt252,
    }

    ////////////////////////////////
    // Constructor
    ////////////////////////////////
    #[constructor]
    fn constructor(
        _tderc20_address: ContractAddress, _players_registry: ContractAddress, _workshop_id: u128, _exercise_id: u128
    ) {
        ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id);
    }


    ////////////////////////////////
    // EVENTS
    ////////////////////////////////
    #[event]
    fn received_something(from: usize, something: usize) {}


    ////////////////////////////////
    // View Functions
    ////////////////////////////////
    #[view]
    fn get_l1_evaluator_address() -> felt252 {
        l1_evaluator_address::read()
    }

    ////////////////////////////////
    // L1 handlers
    ////////////////////////////////
    #[l1_handler]
    fn ex_01_receive_message_from_l1(from_address: felt252, player_l2_address: ContractAddress, player_l1_address: usize, message: usize)
    {
    // Check that the sender is the correct L1 evaluator
    assert(from_address == l1_evaluator_address::read(), 'WRONG L1 EVALUATOR');
    // Credit points to the users and validate exercise
    distribute_points(player_l2_address, 2);
    validate_exercise(player_l2_address);
    // Trigger an event with the user's message
    received_something(player_l1_address, message);
    }

    ////////////////////////////////
    // External Functions
    ////////////////////////////////
    #[external]
    fn ex_02_send_message_to_l1(player_l1_address: felt252, message: usize)
    {
    // Create the message payload
    // By default it's an array of felt252
    let mut message_payload = ArrayTrait::new();
    // Adding the address of the player on L2
    message_payload.append(get_caller_address().into());
    // Adding the address of the player on L1
    message_payload.append(player_l1_address);
    // Adding the message
    message_payload.append(message.into());
    // Sending the message
    send_message_to_l1_syscall(l1_evaluator_address::read(), message_payload.span());
    }
  
    ////////////////////////////////
    // External functions - Administration
    // Only admins can call these. You don't need to understand them to finish the exercise.
    ////////////////////////////////
    #[external]
    fn update_class_hash(class_hash: felt252) {
        update_class_hash_by_admin(class_hash);
    }

    #[external]
    fn update_l1_evaluator_address(_l1_evaluator_address: felt252) {
        
        l1_evaluator_address::write(_l1_evaluator_address);
    }


}