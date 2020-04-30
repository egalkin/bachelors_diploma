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
  if has_solution(system, [system z.']) && ~isempty(system)
%       solution = mod(linsolve(system,z.').',2);
      solution = gauss(system, z);
      idx = 1;
      for i = m * n + 1:length(codeword)
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
    if length(system) ~= length(z) 
        return
    end
    [n, m] = size(system);
    system(1:n, m+1) = z;
    system = unique(system, 'row');
    system = system(any(system,2),:);
    n = size(system, 1);
    z = system(1:n, m+1).';
    system = system(1:n, 1:m);
end

% Проверяем, что матрица обратима.
function has_solution = has_solution(matrix, extended_matrix)
    has_solution = rank(matrix) == size(matrix,2) && rank(matrix) == rank(extended_matrix);
end
