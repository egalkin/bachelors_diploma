e_pr = 0.1;
blocks_num = 3;
m = 2;
L = 3;
n = 2 ^ m;
k = n - 1;
test_num = 100;
added_blocks_num = L;
max_erasures = 2;
correct = 0;

g = [
    1 0 0 1, 0 0 0 1, 0 0 0 1;
    0 1 0 1, 0 0 0 0, 0 0 0 1;
    0 0 1 1, 0 0 0 1, 0 0 0 0;
];

h_row = [[1,1,0,0], [1,0,1,0], [1,1,1,1]];

for test = 1:test_num
message = [randi([0, 1], 1 ,blocks_num * k), zeros(1, added_blocks_num * k)];
encoded_message = encode(g,message, m);
erasure_number = 0;
for i = 1:length(encoded_message)
    erasure = rand;
    if erasure <= e_pr && erasure_number < max_erasures
        encoded_message(i) = -1;
        erasure_number = erasure_number + 1;
    end
end
message = message(1:end-k * added_blocks_num);
decoded_message = decode(h_row ,encoded_message, added_blocks_num, m, L);

if isequal(message, decoded_message)
    correct = correct+1; 
else 
    disp(message)
    disp(encoded_message)
    disp(decoded_message)
    break;
end


end
disp(correct / test_num);




