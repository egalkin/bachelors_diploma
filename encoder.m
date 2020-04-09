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
% Так как в рекурентной формуле нам нужны два предыдущик синдрома, будем их
% сохранять.
last_syndroms = {};
blocks_number = length(message) / k;
v = zeros(1, blocks_number);
encoded_message = zeros(1, blocks_number * n);
% Посчитаем сначала v(1) и v(2) и запишем первые два блока кодового слова.
syndrom = compute_syndrom(message(1:1+k-1), fliplr(h(1:3,2:4)).');
v(1) = syndrom(1);
last_syndroms{1} = syndrom;
encoded_message(1:1+k) = [message(1:1+k-1) v(1)];
syndrom = compute_syndrom(message(4:4+k-1), fliplr(h(1:3,6:8)).');
v(2) = mod(v(1) + last_syndroms{1}(2) + syndrom(1), 2); 
last_syndroms{2} = syndrom;
encoded_message(5:5+k) = [message(4:4+k-1) v(2)];
% Применяем рекурентную формулу и посчитаем v(i), а так же запишем i блок
% кодового слова.
for i = 3:blocks_number
    cur_encoded_block = message((i-1) * k + 1: (i-1) * k + k);
    cur_syndrom = compute_syndrom(cur_encoded_block, fliplr(h(1:3, (i-1) * n + 2 : (i - 1) * n + k + 1)).');
    v(i) = mod (v(i-2) + v(i-1) + last_syndroms{1}(3) + last_syndroms{2}(2) + cur_syndrom(1), 2);
    % Обновляем последние два синдрома.
    last_syndroms{1} = last_syndroms{2};
    last_syndroms{2} = cur_syndrom;
    encoded_message((i-1) * n + 1: (i-1) * n + k + 1) = [cur_encoded_block v(i)];
end
disp(encoded_message)
disp(expected_message)
disp(isequal(encoded_message, expected_message))

% Я подумал, что не надо изобретать велосипед и можно просто использовать
% обычное перемножение матриц, а после вязть модуль.
function syndrom = compute_syndrom(message, sub_h)
    syndrom = mod(message * sub_h, 2);
end

