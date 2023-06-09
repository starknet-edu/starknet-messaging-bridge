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
    use starknet_messaging_bridge::utils::ex00_base::Ex00Base::players_registry;
    use starknet_messaging_bridge::utils::Iplayers_registry::Iplayers_registryDispatcherTrait;
    use starknet_messaging_bridge::utils::Iplayers_registry::Iplayers_registryDispatcher;
    use starknet_messaging_bridge::utils::helper;
    use starknet_messaging_bridge::IEx05_receiver::IEx05_receiverDispatcherTrait;
    use starknet_messaging_bridge::IEx05_receiver::IEx05_receiverDispatcher;

    ////////////////////////////////
    // Storage
    ////////////////////////////////
    struct Storage{
        l1_evaluator_address: felt252,
        ex_05_player_to_receiver: LegacyMap<ContractAddress, ContractAddress>,
        ex_05_receiver_to_rand_value: LegacyMap<ContractAddress, usize>,
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
    // Selector: 0x274ab8abc4e270a94c36e1a54c794cd4dd537eeee371e7188c56ee768c4c0c4
    // Check that the sender is the correct L1 evaluator
    assert(from_address == l1_evaluator_address::read(), 'WRONG L1 EVALUATOR');
    // Adding a check on the message, because why not?
    assert(message > 168111, 'MESSAGE TOO SMALL');
    assert(message < 5627895, 'MESSAGE TOO BIG');
    // Credit points to the users and validate exercise
    distribute_points(player_l2_address, 2);
    validate_exercise(player_l2_address, 1_u128);
    // Trigger an event with the user's message
    received_something(player_l1_address, message);
    }

    #[l1_handler]
    fn ex_03_receive_message_from_l1_contract(from_address: felt252, player_l2_address: ContractAddress)
    {
    // Selector: 0x92d55394e14620606cc8c623ce613f707656dad186f130361aa9ab37638129
    // This function can only be triggered by sending a message from L1.
    // from_address is the L1 address that sent the message to starknet core
    // player_l2_address is the l2 address to whom points will be credited

    // Note that this function can also be triggered by an EOA on L1. Choose your weapon ;-)

    // Credit points to the users and validate exercise
    distribute_points(player_l2_address, 2);
    validate_exercise(player_l2_address, 3_u128);
    }

    #[l1_handler]
    fn ex_05_receive_message_on_an_l2_contract(from_address: felt252, player_l2_receiver: ContractAddress, rand_value: usize, player_l2_address: ContractAddress)
    {
    // Selector: 0x12db22b429341580131c6b522a5c9f6332d59b08a0077777b46e2e0d1ea3a92
    // Sending a message to a custom L2 contract
    // To collect points, you need to deploy an L2 contract that includes an l1 handler that can receive messages from L1.
    // To get point on this exercice you need to
    // - Deploy an L2 contract that will receive message sent from L1
    // - Your L2 contract should record what value was sent, and make it viewable through a getter function
    // - Call ex05SendMessageToAnL2CustomContract on the L1 evaluator
    // - The L1 evaluator sends a message to your contract, as well as to the L2 evaluator (triggering this particular L1 handler)
    // - On L2, you call ex_05_check_result() on the evaluator to show that both values match
    // This L1 handler is called by the L1 evaluator; to complete the exercice, 

    // Check that the sender is the correct L1 evaluator
    assert(from_address == l1_evaluator_address::read(), 'WRONG L1 EVALUATOR');
    // Register the l2 contract of the player
    ex_05_player_to_receiver::write(player_l2_address, player_l2_receiver);
    // Register the random value received 
    ex_05_receiver_to_rand_value::write(player_l2_receiver, rand_value);
    // Credit points to the users and validate exercise
    distribute_points(player_l2_address, 2);
    validate_exercise(player_l2_address, 5_u128);
    }

    #[l1_handler]
    fn validate_from_l1(from_address: felt252, player_l2_address: ContractAddress, exercice_number: u128)
    {
    // Selector: 0x1dc98f1a6c797f34828d0049700af70c9c1d28442d6ae5d2fa1732d773ddf1a
    // Check that the sender is the correct L1 evaluator
    assert(from_address == l1_evaluator_address::read(), 'WRONG L1 EVALUATOR');
    // Credit points to the users and validate exercise
    distribute_points(player_l2_address, 2);
    validate_exercise(player_l2_address, exercice_number);
    }

    ////////////////////////////////
    // External Functions
    ////////////////////////////////
    #[external]
    fn ex_02_send_message_to_l1(message: usize)
    {
    // Sending a message from L2
    // To validate this exercice, you need to:
    // - Use this function on L2 to send a message to L1
    // - Call a function on the L1 evaluator to consume the message 
    // - Be careful! There is a constraint on the value of "message". Check the L1 evaluator to find out which...

    // Create the message payload
    // By default it's an array of felt252
    let mut message_payload = ArrayTrait::new();
    // Adding the address of the player on L2
    message_payload.append(get_caller_address().into());
    // Adding the message
    message_payload.append(message.into());
    // Sending the message
    send_message_to_l1_syscall(l1_evaluator_address::read(), message_payload.span());
    }
  
    #[external]
    fn ex_05_check_result(message: usize)
    {
    // Validating exercice 05
    // You should call this function once you have:
    // - Deployed a L2 contract that can receive messages with a random value from the L1 evaluator
    // - Your L2 contract needs to make the random value readable
    // - Triggered ex05SendMessageToAnL2CustomContract() on L1 evaluator to send a message to your L2 contract
    // - The message has been received

    // Read the L2 receiver contract associated with player
    let l2_receiver_contract = ex_05_player_to_receiver::read(get_caller_address());
    // Read the random value associated with the l2 receiver
    let evaluator_received_rand_value = ex_05_receiver_to_rand_value::read(l2_receiver_contract);
    // Call function read_rand_value() on l2_receiver_contract
    let receiver_received_rand_value = IEx05_receiverDispatcher{contract_address: l2_receiver_contract}.random_value();
    // Compare if both values are equal
    assert(evaluator_received_rand_value==receiver_received_rand_value, 'VALUE MISMATCH');
    // Crediting points
    distribute_points(get_caller_address(), 2);
    validate_exercise(get_caller_address(), 5);
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
        let players_registry = players_registry();
        let sender_address = get_caller_address();

        let is_admin = Iplayers_registryDispatcher{contract_address: players_registry}
            .is_exercise_or_admin(sender_address);

        assert(is_admin, 'CALLER_NO_ADMIN_RIGHTS');
        l1_evaluator_address::write(_l1_evaluator_address);
    }


}