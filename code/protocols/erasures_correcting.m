blocks_num = 100;

H_conv = [
           1 0 2 0 3 0 4 0;
           1 1 5 0 6 0 7 0;
           2 4 5 0 8 0 9 35;
           3 29 6 15 8 0 10 0;
           4 0 7 0 9 0 10 26;
         ];
          
M = 78; 
J = 2;
K = 4;
m = 2;
L = 2;
added_blocks_num = L;
n = 2 ^ m;
k = n - 1;
W = m + L + 1;

protocol_sequences = generate_protocol_sequences(H_conv, M);

if ~verify_H(protocol_sequences, J, K)
    exception = MException("LDPC code parity-check matrix don't satisfy it's characteristic");
    throw(exception);
end


P = size(protocol_sequences, 1);
T = length(protocol_sequences);

frame_number = 200;

users_distr = [2:5:100, 100];
packet_loss_probability = zeros(1, length(users_distr));


test_number = 100;

% Собственно симуляция самого канала. 

for ii = 1:length(users_distr)
    for test = 1:test_number
        active_users = users_distr(ii);
        recieved_messages = zeros(active_users, k * blocks_num);
        current_transmited_subblock = zeros(1, active_users);
        user_access_probability = rand(1, active_users);
        users_protocol_sequences = zeros(active_users, T);
        active_users_state = cell(active_users, 1);
        decoders = cell(active_users);

        users_recieved_blocks_id = cell(active_users, 1);
        need_to_transmit = cell(active_users, 1);
        transmited_packet_id = cell(active_users, 1);
        will_be_transmited = cell(active_users, 1);

        user_sequence = zeros(1, active_users);
        is_user_active = zeros(1, active_users);
        is_sequence_active = zeros(1, P);

        zero_vect = zeros(1,T);

        for user_num = 1:active_users
            decoders{user_num} = Decoder;
            users_recieved_blocks_id{user_num} = 0;
            transmited_packet_id{user_num} = 1;
        end

        successfully_transmited_messages = 0;
        successfully_transmited_packets = 0;

        total_transmitted_messages = 0;
        total_transmitted_packets = 0;

        protocols_shuffle = randperm(length(1:P));

        for frame_number = 1:frame_number
            for sub_frame = 1:T
                for user_num = 1:active_users 
                    if ~is_user_active(user_num) && user_access_probability(user_num) >= rand
                        users_protocol_sequences(user_num, :) = protocol_sequences(protocols_shuffle(user_num), :);
                        if ~isempty(active_users_state{user_num}) 
                            active_users_state{user_num}.reset_state();
                        else
                            active_users_state{user_num} = User(k,n);
                        end
                        is_user_active(user_num) = 1;
                        active_users_state{user_num}.generate_message(blocks_num);
                    end
                    if is_user_active(user_num)
                        if isempty(need_to_transmit{user_num})
                            need_to_transmit{user_num} = active_users_state{user_num}.get_current_transmitted_block;
                        end
                        if isempty(need_to_transmit{user_num})
                            decoded_block = decoders{user_num}.finalize;
                            id = users_recieved_blocks_id{user_num};
                            recieved_messages(user_num, k*id+1:k*id+k) = decoded_block;
                            message = active_users_state{user_num}.get_message;
                            if isequal(recieved_messages(user_num,:), message)
                                successfully_transmited_messages = successfully_transmited_messages + 1;
                                successfully_transmited_packets = successfully_transmited_packets + length(message)/ n;
                            else 
                                for i = 1:length(message)/n
                                   if isequal(recieved_messages(user_num, (i-1)*k+1:(i-1)*k+k), message((i-1)*k+1:(i-1)*k+k))
                                       successfully_transmited_packets = successfully_transmited_packets + 1;
                                   end
                                end
                            end
                            total_transmitted_messages = total_transmitted_messages + 1;
                            total_transmitted_packets = total_transmitted_packets + length(message)/ n;
                            users_recieved_blocks_id{user_num} = 0;
                            is_user_active(user_num) = 0;
                        end
                        if transmited_packet_id{user_num} > n
                            transmited_packet_id{user_num} = 1;
                        end
                    end
                end 

               current_seqs_state = sum(users_protocol_sequences(:,sub_frame) == 1);
               for user_num = 1:active_users            
                   if is_user_active(user_num) && users_protocol_sequences(user_num, sub_frame) && ~isempty(need_to_transmit{user_num})
                       if current_seqs_state > 1
                           will_be_transmited{user_num} = [will_be_transmited{user_num}, -1];
                       else 
                           will_be_transmited{user_num} = [will_be_transmited{user_num}, need_to_transmit{user_num}(transmited_packet_id{user_num})];
                       end
                       transmited_packet_id{user_num} = transmited_packet_id{user_num} + 1;
                   end
               end
            end

            for user_num = 1:active_users
                if length(will_be_transmited{user_num}) == n
                    decoded_block = decoders{user_num}.decode(will_be_transmited{user_num});
                    if ~isempty(decoded_block)
                        id = users_recieved_blocks_id{user_num};
                        recieved_messages(user_num, k*id+1:k*id+k) = decoded_block;
                        users_recieved_blocks_id{user_num} = id + 1;
                    end 
                    will_be_transmited{user_num} = [];
                    need_to_transmit{user_num} = [];
                end
            end
        end

        packet_loss_probability(ii) = packet_loss_probability(ii) +  (1 - successfully_transmited_packets / total_transmitted_packets);
    end
    packet_loss_probability(ii) = packet_loss_probability(ii) / test_number;
end


semilogy(users_distr, packet_loss_probability);
xlabel("Num of users in channel");
ylabel("Packet loss probability"); 


