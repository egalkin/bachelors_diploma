% H_conv = [
%            1 0 2 0 3 0 4 0;
%            1 1 5 0 6 0 7 0;
%            2 4 5 0 8 0 9 35;
%            3 29 6 15 8 0 10 0;
%            4 0 7 0 9 0 10 26;
%          ];
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


P = size(protocol_sequences, 1);

max_user_num = P;

T = length(protocol_sequences);
t = 4;

access_probability = 0.1;

users_protocol_sequences = zeros(1, P);
conflicts = zeros(1, T);
active_users_distr = zeros(1,T);

unique_seqs = 0;

protocols_shuffle = randperm(length(1:P));

% Симуляция доступа в канал и оценка конфликтов на подкадр.

for i = 1:T
    for user_num = 1:max_user_num
        if users_protocol_sequences(user_num) == 0 && access_probability >= rand 
            if unique_seqs
                users_protocol_sequences(user_num) = protocols_shuffle(user_num);
            else 
                users_protocol_sequences(user_num) = randi(P);
            end
        end
    end
    active_users = find(users_protocol_sequences); 
    subframe_behaviour = zeros(1, length(active_users));
    for j = 1:length(active_users)
        subframe_behaviour(j) = protocol_sequences(users_protocol_sequences(active_users(j)), i);
    end
    active_users_distr(i) = length(active_users);
    transmissions_num = sum(subframe_behaviour == 1);
    conflicts(i) = transmissions_num;   
end


figure
plot(1:T, conflicts)
xlabel('Subframe num')
ylabel('Conflicts number')

figure
plot(1:T, active_users_distr)
xlabel('Subframe num')
ylabel('Users number')


