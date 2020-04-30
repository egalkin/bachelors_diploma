function decoded_message = decode(encoded_message, added_blocks_num)
    h = [
        [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0], [0,0,0,0];
        [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0];
        [0,0,0,0], [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1]
        ];

    m = 2;
    L = 2;
    W = m + L + 1;
    n = 2 ^ m;
    k = n - 1;

    % Добавляем нули в начала и конец, в конец, так как последовательность не
    % полубесконечная и чтобы все декодировать это было нужно.
    real_blocks_num = length(encoded_message) / n - added_blocks_num;
    encoded_message = [zeros(1,n * m), encoded_message];
    blocks_num = length(encoded_message) / n;
    decoded_message = zeros(1, real_blocks_num * k);
    l = 0;
    r = W;
    % Двигаем окно вдоль кодового слова и декодируем.
    while r <= blocks_num
      [decoded_window, codeword_subblock] = decode_in_window(encoded_message(l*n+1:r*n), m, h);
      decoded_message(l*k+1:l*k+k) = decoded_window;
      encoded_message(l*n+1:r*n) = codeword_subblock;
      l = l + 1;
      r = r + 1;
    end
    encoded_message = encoded_message(9:end);
    decoded_message = zeros(1, k * real_blocks_num);
    for i = 0:real_blocks_num-1
        decoded_message(i * k + 1: i * k + 3) = encoded_message(i * n + 1 : i * n + 3);
    end
end

