h = [
    [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0], [0,0,0,0];
    [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0];
    [0,0,0,0], [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1]
    ];
    
message = [1 1 0 1 1 0 0 0 1 0 0 0 1 0 1];
expected_message = [1 1 0 0 1 1 0 1 0 0 1 0 0 0 0 1 1 0 1 0];


m = 2;
L = 2;
W = m + L + 1;
n = 2 ^ m;
k = n - 1;
last_syndroms = {};
blocks_number = length(message) / k;
v = zeros(1, blocks_number);
encoded_message = zeros(1, blocks_number * n);
syndrom = compute_syndrom(message(1:1+k-1), h(1:3,1:3).');
v(1) = syndrom(1);
last_syndroms{1} = syndrom;
encoded_message(1:1+k) = [message(1:1+k-1) v(1)];
syndrom = compute_syndrom(message(4:4+k-1), h(1:3,5:7).');
v(2) = mod(v(1) + last_syndroms{1}(2) + syndrom(1), 2); 
last_syndroms{2} = syndrom;
encoded_message(5:5+k) = [message(4:4+k-1) v(2)];
for i = 3:blocks_number
    cur_encoded_block = message((i-1) * k + 1: (i-1) * k + k);
    disp(h(1:3, (i-1) * n + 1 : (i - 1) * n + k))
    cur_syndrom = compute_syndrom(cur_encoded_block, h(1:3, (i-1) * n + 1 : (i - 1) * n + k).');
    v(i) = mod (v(i-2) + v(i-1) + last_syndroms{1}(3) + last_syndroms{2}(2) + cur_syndrom(1), 2);
    last_syndroms{1} = last_syndroms{2};
    last_syndroms{2} = cur_syndrom;
    encoded_message((i-1) * n + 1: (i-1) * n + k + 1) = [cur_encoded_block v(i)];
end
disp(encoded_message)
disp(expected_message)

function syndrom = compute_syndrom(message, h)
    syndrom = mod(message * h, 2);
end

