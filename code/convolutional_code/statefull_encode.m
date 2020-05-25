function [encoded_message, state] = statefull_encode(message, g_formated, state, m)    
    n = 2 ^ m;
    k = n - 1;
    blocks_number = length(message) / k;
    encoded_message = zeros(1, blocks_number * n);
    
    for i = 1:blocks_number
        cur_encoded_block = message((i-1) * k + 1: (i-1) * k + k);
        v = mod(sum(cur_encoded_block), 2);
        for j = 1 : size(state,2)
            v = xor(v, mod(state(:,j).' * g_formated(:, j),2));
        end
        for cell = size(state,2):-1:2
            state(:,cell) = state(:, cell-1);
        end
        state(:,1) = cur_encoded_block.';
        for k = 1:size(g_formated,1)
            j = size(g_formated,2);
            while j > 0 && g_formated(k,j) == 0
                state(k,j) = 0;
                j = j -1;
            end
        end
        encoded_message((i-1) * n + 1: (i-1) * n + n) = [cur_encoded_block v];
    end
end
