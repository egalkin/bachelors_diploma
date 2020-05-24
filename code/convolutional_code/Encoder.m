classdef Encoder < handle
    properties 
         g_formated = [1 0 1; 1 1 0].';
         state = zeros(3, 2);
    end
    methods 
        function encoded_block = encode(obj, block)
            [encoded_block, obj.state] = statefull_encode(block, obj.g_formated, obj.state);
        end
        function clear_state(obj)
            obj.g_formated = [1 0 1; 1 1 0].';
            obj.state = zeros(3, 2);
        end
    end
end