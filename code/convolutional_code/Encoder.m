classdef Encoder < handle
    properties 
         m = 2;
         g_formated = [1 0 1; 1 1 0].';
         state = zeros(3, 2);
    end
    methods 
        function obj = Encoder(g_formated, m)
            if nargin == 2
                obj.m = m;
                obj.g_formated = g_formated;
                obj.state = zeros(size(obj.g_formated,1), size(obj.g_formated,2));
            end
        end
        function encoded_block = encode(obj, block)
            [encoded_block, obj.state] = statefull_encode(block, obj.g_formated, obj.state, obj.m);
        end
        function clear_state(obj)
            obj.state = zeros(size(obj.g_formated,1), size(obj.g_formated,2));
        end
    end
end