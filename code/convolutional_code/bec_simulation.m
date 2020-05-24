e_pr = 0.1;
blocks_num = 100;
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

for test = 1:test_num
message = [randi([0, 1], 1 ,blocks_num * k), zeros(1, added_blocks_num * k)];
encoded_message = encode(message);
% disp(mod(encoded_message * h.', 2) == 0);
erasure_number = 0;
for i = 1:length(encoded_message) - k * added_blocks_num
    erasure = rand;
    if erasure <= e_pr && erasure_number < max_erasures
        encoded_message(i) = -1;
        erasure_number = erasure_number + 1;
    end
end
message = message(1:end-k * added_blocks_num);
decoded_message = decode(encoded_message, added_blocks_num);

if isequal(message, decoded_message)
    correct = correct+1;
end
end

disp(correct / test_num);




