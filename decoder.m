h = [
    [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0], [0,0,0,0];
    [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0];
    [0,0,0,0], [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1]
    ];
    

codeword = "1100 1f0f 001f 0001 10f0";

splited_codeword = strsplit(codeword);

m = 2;
L = 2;
W = m + L + 1;
n = 2 ^ m;
converted_codeword = [];
indexing = 1;
% Преобразуем кодовое слово в список, стирания я заменил пока на -1.
for i = 1:length(splited_codeword)
  code_block = splited_codeword{i};
  for j = 1:length(code_block)
    if code_block(j) ~= 'f'
      converted_codeword(indexing) = code_block(j) - '0';
    else
      converted_codeword(indexing) = -1;
    end
    indexing = indexing + 1;
  end
end
% Добавляем нули в начала и конец, в конец, так как последовательность не
% полубесконечная и чтобы все декодировать это было нужно.
converted_codeword = [zeros(1,n * m), converted_codeword, zeros(1,n * m)];
blocks_num = length(converted_codeword) / n;
decoded_word = [];
l = 0;
r = W;
% Двигаем окно вдоль кодового слова и декодируем.
while r <= blocks_num
  [decoded_window, codeword_subblock] = decode_in_window(converted_codeword(l*n+1:r*n), m, h);
  decoded_word = [decoded_word, decoded_window];
  converted_codeword(l*n+1:r*n) = codeword_subblock;
  l = l + 1;
  r = r + 1;
end
disp(decoded_word)





