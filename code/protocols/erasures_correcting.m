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

max_frame_number = 200;

users_distr = [2:5:100, 100];
packet_loss_probability = zeros(1, length(users_distr));
uncoded_packet_loss_probability = zeros(1, length(users_distr));


test_number = 1000;

% Собственно симуляция самого канала. Так как в matlab несильно развито
% ООП, симуляция канала отчасти была написана процедурно, отчасти в ООП
% стиле.

for ii = 1:length(users_distr)
    % Деламе тесты для конкретного значения числа активных пользователей,
    % что бы взять после среднее значение вероятности потери пакета.
    for test = 1:test_number
        %Число активных пользователей.
        active_users = users_distr(ii);
        % Полученные от пользователей сообщения
        recieved_messages = zeros(active_users, k * blocks_num);
        uncoded_recieved_messages = zeros(active_users, k * blocks_num);
        % Вероятность выхода в канал пользователем
        user_access_probability = rand(1, active_users);
        acess_probability = sum(user_access_probability) / length(user_access_probability);
        % Протокольные последовательности, используемые пользователями
        users_protocol_sequences = zeros(active_users, T);
        % Стэйт пользователя. Для подробностей смотри класс User
        active_users_state = cell(active_users, 1);
        % Декодеры пользователей.
        decoders = cell(active_users);
                
        users_recieved_blocks_id = cell(active_users, 1);
        uncoded_recieved_blocks_id = cell(active_users, 1);
        % Данные, которые хотим передать.
        need_to_transmit = cell(active_users, 1);
        transmited_packet_id = cell(active_users, 1);
        % Данные, которые будут переданы, с учетом стираний.
        will_be_transmited = cell(active_users, 1);

        % Последовательность закрепленная за пользователем
        user_sequence = zeros(1, active_users);
        % Два массива показывающие активность конкретного пользователя и
        % конкретной последовательности.
        is_user_active = zeros(1, active_users);
        is_sequence_active = zeros(1, P);

        % Инициализируем состояние перед запуском тестов.
        for user_num = 1:active_users
            decoders{user_num} = Decoder;
            users_recieved_blocks_id{user_num} = 0;
            uncoded_recieved_blocks_id{user_num} = 0;
            transmited_packet_id{user_num} = 1;
        end

        % Статистика, которую мы будем считать
        successfully_transmited_messages = 0;
        uncoded_successfully_transmited_packets = 0;
        successfully_transmited_packets = 0;

        total_transmitted_messages = 0;
        total_transmitted_packets = 0;
       
        % Шафлим последовательности и назначем каждому пользователю свою,
        % уникальную, мешаем заново каждый тест
        protocols_shuffle = randperm(length(1:P));

        % Начинаем передачу 
        for frame_number = 1:max_frame_number
            % Выход пользователя синхронизирована по подкадрам.
            for sub_frame = 1:T
                for user_num = 1:active_users 
                    % Пользователи пытаются выйти в канал.
                    if ~is_user_active(user_num) && acess_probability >= rand
                        users_protocol_sequences(user_num, :) = protocol_sequences(protocols_shuffle(user_num), :);
                        % Если пользователь выходит впервые инициализируем
                        % для него стейт, если повторно, то очищаем старый
                        % стейт.
                        if ~isempty(active_users_state{user_num}) 
                            active_users_state{user_num}.reset_state();
                        else
                            active_users_state{user_num} = User(k,n);
                        end
                        is_user_active(user_num) = 1;
                        active_users_state{user_num}.generate_message(blocks_num);
                    end
                    % Если пользователь активен.
                    if is_user_active(user_num)
                        % Если ему нечего передавать достаем данные. Может
                        % быть непустое, если пользователь начал передавать
                        % данные посередине кадра и не успел все передать.
                        if isempty(need_to_transmit{user_num})
                            need_to_transmit{user_num} = active_users_state{user_num}.get_current_transmitted_block;
                        end
                        % Если пользователю больше нечего передавать, можем
                        % посчитать статистику.
                        if isempty(need_to_transmit{user_num})
                            % Достанем последний блок пользователя.
                            decoded_block = decoders{user_num}.finalize;
                            id = users_recieved_blocks_id{user_num};
                            recieved_messages(user_num, k*id+1:k*id+k) = decoded_block;
                            message = active_users_state{user_num}.get_message;
                            % Считаем статистику.        
                            successfully_transmited_packets = successfully_transmited_packets + sum(recieved_messages(user_num,:)~=-1);
                            uncoded_successfully_transmited_packets = uncoded_successfully_transmited_packets + sum(uncoded_recieved_messages(user_num, 1:length(message))~=-1);
                            total_transmitted_packets = total_transmitted_packets + length(message);
                            users_recieved_blocks_id{user_num} = 0;
                            uncoded_recieved_blocks_id{user_num} = 0;
                            is_user_active(user_num) = 0;
                        end
                        if transmited_packet_id{user_num} > n
                            transmited_packet_id{user_num} = 1;
                        end
                    end
                end 
               
               % Собираем данные для отправки.
               % Смотрим сколько пересечений по последовательностям есть в
               % подкадре. Если больше одной то получаем коллизию.
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

            % Передаем данные. 
            for user_num = 1:active_users
                if length(will_be_transmited{user_num}) == n
                    unc_id = uncoded_recieved_blocks_id{user_num};
                    uncoded_recieved_messages(user_num, k*unc_id+1:k*unc_id+k) = will_be_transmited{user_num}(1:n-1);
                    uncoded_recieved_blocks_id{user_num} = unc_id + 1;
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
        uncoded_packet_loss_probability(ii) = uncoded_packet_loss_probability(ii) +  (1 - uncoded_successfully_transmited_packets / total_transmitted_packets);
    end
    packet_loss_probability(ii) = packet_loss_probability(ii) / test_number;
    uncoded_packet_loss_probability(ii) = uncoded_packet_loss_probability(ii) / test_number;
end


semilogy(users_distr, uncoded_packet_loss_probability, users_distr, packet_loss_probability);
legend('Uncoded', 'SWML');
xlabel("Число пользователей в канале");
ylabel("Вероятность потери пакета");