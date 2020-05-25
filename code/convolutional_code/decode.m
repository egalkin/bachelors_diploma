function decoded_message = decode(h_row, encoded_message, added_blocks_num, m, L)

    W = m + L + 1;
    n = 2 ^ m;
    k = n - 1;
    
    h_row = [h_row, zeros(1, (W - length(h_row) / n) * n)];
    h = zeros(W-m, W * n);
    for i = 0:W-m-1
        h(i+1, :) = circshift(h_row, i * n , 2);
    end 

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
    if added_blocks_num > L
        decoded_message = decoded_message(1:end - k * (added_blocks_num - m));
    end
    
end

