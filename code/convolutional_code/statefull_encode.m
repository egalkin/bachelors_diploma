function [encoded_message, state] = statefull_encode(message, g, state, m)    
    n = 2 ^ m;
    k = n - 1;
    max_degree = m;
    blocks_number = length(message) / k;
    encoded_message = zeros(1, blocks_number * n);
    
    for i = 1:blocks_number
        cur_block = message((i-1) * k + 1: (i-1) * k + k);
        encoded_block = zeros(1, n);
        for deg = 0:max_degree
            if deg == 0
                encoded_block = xor(encoded_block, mod(cur_block * g(:, deg*n+1:deg*n+n),2));
            else
                encoded_block = xor(encoded_block, mod(state(:,deg).' * g(:, deg*n+1:deg*n+n), 2));
            end
        end
        for cell = size(state,2):-1:2
            state(:,cell) = state(:, cell-1);
        end
        state(:,1) = cur_block.';
        for k = 1:size(g,1)
            j = size(g,2);
            while j > 0 && g(k,j) == 0
                state(k,j) = 0;
                j = j -1;
            end
        end
        encoded_message((i-1) * n + 1: (i-1) * n + n) = encoded_block;
    end
end
