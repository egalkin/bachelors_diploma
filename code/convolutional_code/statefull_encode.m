function [encoded_message, state] = statefull_encode(message, g_formated, state)    
    m = 2;
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
        state(:,2) = state(:,1);
        state(:,1) = cur_encoded_block.';
        state(end,end) = 0;
        
        encoded_message((i-1) * n + 1: (i-1) * n + n) = [cur_encoded_block v];
    end
end
