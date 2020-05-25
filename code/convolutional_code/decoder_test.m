
e_pr = 0.1;
blocks_num = 1000;
m = 2;
L = 2;
W = 5;
k = 3;
n = 4;
test_num = 100;
added_blocks_num = 2;
max_erasures = 2;

correct = 0;

g_formated = [1 0 1; 1 1 0].';
h_row = [[1,1,0,0], [1,0,1,0], [1,1,1,1]];

decoder = Decoder(h_row, m, L);

test_passed = 1;

for test = 1:test_num
    message = [randi([0, 1], 1 ,blocks_num * k), zeros(1, added_blocks_num * k)];
    encoded_message = encode(g_formated, message, m);
    erasure_number = 0;
    for i = 1:length(encoded_message) - k * added_blocks_num
        erasure = rand;
        if erasure <= e_pr && erasure_number < max_erasures
            encoded_message(i) = -1;
            erasure_number = erasure_number + 1;
        end
    end
    message = message(1:end-k * added_blocks_num);
    decoded_message1 = decode(h_row, encoded_message, added_blocks_num, m, L);
    decoded_message2 = zeros(1, blocks_num * k);
    for i = 1:W-m
        decoder.decode(encoded_message((i-1)*n+1:(i-1)*n+n));
    end
    for i = W-m+1:length(encoded_message)/n
        decoded_message2((i-W+m-1)*k+1:(i-W+m-1)*k+k) = decoder.decode(encoded_message((i-1)*n+1:(i-1)*n+n));
    end
    decoded_message2(end-k+1:end) = decoder.finalize;

    test_passed = test_passed && isequal(message, decoded_message1,decoded_message2);
    
    if ~test_passed
        break;
    end
        
end

if ~test_passed
    disp(message)
    disp(decoded_message1)
    disp(decoded_message2)
end

assert(test_passed == 1, 'Test failed')
disp(test_passed)





