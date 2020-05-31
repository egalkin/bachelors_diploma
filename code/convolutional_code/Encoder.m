% Класс используется для кодирования при передаче данных по каналу, хранит
% в себе состояние регистров сдвига кода.

classdef Encoder < handle
    properties 
         m = 2;
         g = [
            1 0 0 1, 0 0 0 1, 0 0 0 1;
            0 1 0 1, 0 0 0 0, 0 0 0 1;
            0 0 1 1, 0 0 0 1, 0 0 0 0;
         ];
        state = zeros(3, 2);
         
    end
    methods 
        function obj = Encoder(g, m)
            if nargin == 2
                obj.m = m;
                obj.g = g;
                obj.state = zeros(size(g,1), m);
            end
        end
        function encoded_block = encode(obj, block)
            [encoded_block, obj.state] = statefull_encode(block, obj.g, obj.state, obj.m);
        end
        function clear_state(obj)
            obj.state = zeros(size(obj.g,1), size(obj.g,2));
        end
    end
end