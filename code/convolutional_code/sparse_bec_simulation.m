blocks_num = 1000;
W = 5;
k = 3;
n = 4;
test_num = 100;
added_blocks_num = 2;
max_erasures = 2;

h = [
    [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0], [0,0,0,0];
    [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0];
    [0,0,0,0], [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1]
    ];

correct = 0;

blocks_values = (5:100);
probs = zeros(1, length(blocks_values));
erasures_number = zeros(1, length(blocks_values));

for block = 1: length(blocks_values)
    correct = 0;
    mid_earausre_num = 0;
    for test = 1:test_num
        message = [randi([0, 1], 1 ,blocks_num * k), zeros(1, added_blocks_num * k)];
        encoded_message = encode2(message);
        erasure_number = 0;
        for i = 1:(length(encoded_message) - k * added_blocks_num)/(blocks_values(block) * n)
            ins_er_pr = 0.3;
            cur_bl_er = 0;
            fin = i * 20;
            st = fin - 19;
            for j = st:fin
                erasure = rand;
                if erasure <= ins_er_pr && cur_bl_er < 2
                    encoded_message(j) = -1;
                    erasure_number = erasure_number + 1;
                    cur_bl_er = cur_bl_er + 1;
                end
            end
        end
        message = message(1:end-k * added_blocks_num);
        decoded_message = decode(encoded_message, added_blocks_num);
        if isequal(message, decoded_message)
            correct = correct+1;
        end
        mid_earausre_num = mid_earausre_num + erasure_number;
    end
    recovery_prob = correct / test_num;
    disp(recovery_prob)
    probs(block) = recovery_prob;
    erasures_number(block) = mid_earausre_num / test_num;
end

subplot(2,1,1);
plot(blocks_values, probs)
% xlabel('Window size')
% ylabel('Recovery probability')

subplot(2,1,2); 
plot(blocks_values, erasures_number)
% xlabel('Window size')
% ylabel('Erasures number')