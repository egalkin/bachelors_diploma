
blocks_num = 3;
m = 3;
W = 5;
n = 2 ^ m;
k = n - 1;

test_num = 100;

test_passed = 1;

g_formated = [1 1 1 1 0 0 0; 1 1 0 0 1 1 0 ; 1 0 1 0 1 0 1].';

encoder = Encoder(g_formated, m);

for i = 1:test_num
    message = randi([0, 1], 1 ,blocks_num * k);
    encoded_message1 = encode(g_formated, message, m);
    encoded_message2 = zeros(1, blocks_num * n);
    for j = 1:blocks_num
        encoded_message2((j-1)*n+1 : (j-1)*n+n) = encoder.encode(message((j-1)*k+1 : (j-1)*k+k));
    end
    test_passed = test_passed && isequal(encoded_message1, encoded_message2);
    if ~test_passed
        break;
    end
    encoder.clear_state
end


if ~test_passed
    disp(message)
    disp(encoded_message1)
    disp(encoded_message2)
end

assert(test_passed == 1, 'Test failed')

disp(test_passed)

