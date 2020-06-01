H_conv = [
     1 0 2 0 3 0;
     1 0 2 1 3 3;
];

          
M = 7; 
J = 2;
K = 3;
protocol_sequences = generate_protocol_sequences(H_conv, M);

if ~verify_H(protocol_sequences, J, K)
    exception = MException("LDPC code parity-check matrix don't satisfy it's characteristic");
    throw(exception);
end

M = size(protocol_sequences, 1);
N = length(protocol_sequences);

active_users_distr = 2:M;
access_probabilities = 0.1:0.2:0.9;
packet_loss_probabilities = zeros(length(access_probabilities), length(active_users_distr));


% Считаем вероятность потери пакета для пользователя по формуле из ПЗ.

for ii = 1:length(access_probabilities)
    access_probability = access_probabilities(ii);
    for k = 2:M
        packet_loss_probabilities(ii,k-1) = count_packet_loss_probability(M, N, k, access_probability, protocol_sequences);
    end
end

plot(active_users_distr, packet_loss_probabilities(1,:)...
        ,active_users_distr, packet_loss_probabilities(2,:)...
        ,active_users_distr, packet_loss_probabilities(3,:)...
        ,active_users_distr, packet_loss_probabilities(4,:)...
        ,active_users_distr, packet_loss_probabilities(5,:)...
        );
    
legend('Access probability = 0.1'...
      ,'Access probability = 0.3'...
      ,'Access probability = 0.5'...
      ,'Access probability = 0.6'...
      ,'Access probability = 0.9'...
      );
 
xlabel('Active users num');
ylabel('Packet loss probability');

function loss_probability = count_packet_loss_probability(M, N, k, access_probability, protocol_sequences) 
    k_active_users_prob = count_k_active_users_prob(M, k, access_probability);
    loss_probability = (k_active_users_prob * count_weight_func(M, N, k, protocol_sequences) * M) / (N * nchoosek(M, k));
end
    
function weight = count_weight_func(M, N, k, protocol_sequences)
    protocols_combinations = nchoosek(2:M, k);
    weight = 0;
    for i = 1:size(protocols_combinations, 1)
        comb = protocols_combinations(i, :);
        fix_seq = protocol_sequences(1,:);
        conf_seq = zeros(1, N);
        for j = 1:length(comb)
            conf_seq = conf_seq | protocol_sequences(comb(j), :);
        end
        weight = weight + sum((fix_seq & conf_seq) == 1);
    end
end

function prob = count_k_active_users_prob(M, k, access_probability)
    prob = nchoosek(M, k) * access_probability ^ k * (1 - access_probability) ^ (M - k);
end

