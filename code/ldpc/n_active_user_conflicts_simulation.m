% H_conv = [
%            1 0 2 0 3 0 4 0;
%            1 1 5 0 6 0 7 0;
%            2 4 5 0 8 0 9 35;
%            3 29 6 15 8 0 10 0;
%            4 0 7 0 9 0 10 26;
%          ];
%      
H_conv = [
     1 0 2 0 3 0;
     1 0 2 1 3 3;
];
     
M = 7; 
J = 2;
L = 3;
protocol_sequences = generate_protocol_sequences(H_conv, M);

if ~verify_H(protocol_sequences, J, L)
    exception = MException("LDPC code parity-check matrix don't satisfy it's characteristic");
    throw(exception);
end

P = size(protocol_sequences, 1);

max_user_num = P;

T = length(protocol_sequences);
t = 4;

avg_transmissions = zeros(1, P);

for active_protocols_num = 2:P 
    protocols_usage = multicombination(1:P, active_protocols_num);
    avg_transmission_number = 0;
    for i = 1:size(protocols_usage, 1)
        conflicts = zeros(1, T);
        cur_protocols_distr = protocols_usage(i,:);
        for s = 1:T
            subframe_behaviour = zeros(1, active_protocols_num);
            for j = 1:active_protocols_num
                subframe_behaviour(j) = protocol_sequences(cur_protocols_distr(j), t);
            end
            conflicts(i) = sum(subframe_behaviour == 1);
        end
        avg_transmission_number = avg_transmission_number + mean(conflicts);
    end
    avg_transmissions(active_protocols_num) = avg_transmission_number / size(protocols_usage, 1);
end

figure
plot(1:P, avg_transmissions)
xlabel('Active protocol seqeunces num')
ylabel('Average transmission number')