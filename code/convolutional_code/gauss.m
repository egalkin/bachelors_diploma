%{
    Решение системы методом Гаусса над полем GF(2). Нашел решение в интернете
    и немного его преобразовал. Потенциально можно использовать linsolve, а
    после вызывать mod(solution,2).
%}
function x = gauss(a, b)
    [n, m] = size(a);
    for col = 1:m
        if ~a(col, col) 
            for i = 1:n
                if a(i, col) 
                    a([i col], :) = a([col i], :);
                    b([i col]) = b([col i]);      
                end
            end
        end
        if ~a(col, col) 
            continue
        end
        for i = 1:n 
            if i~=col && a(i, col)
                a(i,:) = xor(a(i, :), a(col, :));
                b(i) = xor(b(i), b(col));
            end
        end
    end
    x = b;
end 
