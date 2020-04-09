%{
    Здесь мы получается декодируем код из нашего окна. Сначала мы строим
    систему уравнений умножив codewor на проверочную матрицу. После мы
    смотрим чтоб, система была квадратной и если нет, то преобразуем ее
    удалив нулевые строки. После преобразований проверим то, что матрица
    обратима. Дальше решаем ее методом гаусса и подставляем
    восстановленные значения на стертые позиции. 
%}
function [decoded_block, codeword] =  decode_in_window(codeword, m, h) 
  n = 2 ^ m;
  [system, z] = build_system(codeword, h);
  [system, z] = preprocess_system(system, z);
  if is_invertible(system) && ~isempty(system)
      solution = gauss(system, z);
      idx = 1;
      for i = 1:length(codeword)
          if codeword(i) == -1
              codeword(i) = solution(idx);
              idx = idx + 1;          
          end
      end
  end
  decoded_block = codeword(m * n + 1: m * n + n - 1);
end

%{
   Преобразуем систему к квадратному виду путем удаления лишних нулевых
   строк.
%}
function [system, z] = preprocess_system(system, z)
    if length(system) > length(z) 
        return
    end
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

% Проверяем, что матрица обратима.
function invertible = is_invertible(system)
    invertible = size(system,1) == size(system,2) && rank(system) == size(system,1);
end
