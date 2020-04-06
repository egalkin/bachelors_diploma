h = [
    [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0], [0,0,0,0];
    [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1], [0,0,0,0];
    [0,0,0,0], [0,0,0,0], [1,1,0,0], [1,0,1,0], [1,1,1,1]
    ];
    

codeword = "1100 1f0f 0010 0001 1010";

splited_codeword = strsplit(codeword);

m = 2;
L = 2;
W = m + L + 1;
n = 2 ^ m;
converted_codeword = [];
indexing = 1;
for i = 1:size(splited_codeword,2)
  code_block = splited_codeword{i};
  for j = 1:size(code_block,2)
    if code_block(j) ~= 'f'
      converted_codeword(indexing) = code_block(j) - '0';
    else
      converted_codeword(indexing) = -1;
    end
    indexing = indexing + 1;
  end
end
converted_codeword = [zeros(1,n * m), converted_codeword, zeros(1,n * m)];
blocks_num = size(converted_codeword,2) / n;
decoded_word = [];
l = 0;
r = W;
while r <= blocks_num
  [decoded_window, codeword_subblock] = decode_in_window(converted_codeword(l*n+1:r*n), m, h);
  decoded_word = [decoded_word, decoded_window];
  converted_codeword(l*n+1:r*n) = codeword_subblock;
  l = l + 1;
  r = r + 1;
end
disp(decoded_word)

function [system, syndrom] = build_system(codeword, h) 
  syndrom = [];
  system = [];
  indexing = 1;
  for r = 1:size(h,1)
    system_indexing = 1;
    bits = 0;
    system_column = [];
    for i = 1:size(codeword,2)
      if codeword(i) >= 0
        bits = bits + codeword(i) * h(r, i);
      else
        system_column(system_indexing) = abs(codeword(i)) * h(r,i);
        system_indexing = system_indexing + 1;
      end
    end
    bits = mod(bits,2);
    system = [system; system_column];
    syndrom(indexing) = bits;
    indexing = indexing + 1;
  end
end

function [system, z] = preprocess_system(system, z)
    while size(system,1) ~= size(system,2)
        for i = 1:size(system,1)
            if system(i, :) == 0
                system(i, :) = [];
                z(i) = [];
                break
            end
        end
    end
end

function invertible = is_invertible(system)
    invertible = size(system,1) == size(system,2) && rank(system) == size(system,1);
end

function [decoded_block, codeword] =  decode_in_window(codeword, m, h) 
  n = 2 ^ m;
  decoded_block = [];
  [system, z] = build_system(codeword, h);
  [system, z] = preprocess_system(system, z);
  if is_invertible(system) && ~isempty(system)
      solution = mod(linsolve(system, z.').', 2);
      idx = 1;
      for i = 1:size(codeword,2)
          if codeword(i) == -1
              codeword(i) = solution(idx);
              idx = idx + 1;          
          end
      end
  end
  decoded_block = codeword(m * n + 1: m * n + n - 1);
end
