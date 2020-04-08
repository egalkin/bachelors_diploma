function [decoded_block, codeword] =  decode_in_window(codeword, m, h) 
  n = 2 ^ m;
  [system, z] = build_system(codeword, h);
  [system, z] = preprocess_system(system, z);
  if is_invertible(system) && ~isempty(system)
      solution = gauss(system, z);
      disp(solution)
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