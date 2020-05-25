classdef Decoder < handle
    properties 
        h_row = [[1,1,0,0], [1,0,1,0], [1,1,1,1]]
        h;
        m = 2;
        L = 2;
        W;
        n;
        k;
        window_state;
    end
    methods 
        function obj = Decoder(h_row, m, L)
            if nargin == 3
                obj.h_row = h_row;
                obj.m = m;
                obj.L = L; 
            end
            obj.W = obj.m + obj.L + 1;
            obj.n = 2 ^ obj.m;
            obj.k = obj.n - 1;
            obj.window_state = zeros(1, obj.m * obj.n);
            obj.h_row = [obj.h_row, zeros(1, (obj.W - length(obj.h_row) / obj.n) * obj.n) ];
            obj.h = zeros(obj.W-obj.m, obj.W * obj.n);
            for i = 0:obj.W-obj.m-1
                obj.h(i+1, :) = circshift(obj.h_row, i * obj.n , 2);
            end
        end
        function decoded_block = decode(obj, block)
            if length(obj.window_state) / obj.n == obj.W
                [decoded_block, codeword_subblock] = decode_in_window(obj.window_state, obj.m, obj.h);
                obj.window_state = [codeword_subblock(obj.n+1:end), block];
            else
                decoded_block = [];
                obj.window_state = [obj.window_state, block];
            end
        end
        function decoded_block = finalize(obj)
            if length(obj.window_state) / obj.n == obj.W
                decoded_block = decode_in_window(obj.window_state, obj.m, obj.h);
            else
                decoded_block = [];
            end
            obj.clear_state;
        end
        function clear_state(obj)
            obj.window_state = zeros(1, obj.m * obj.n);
        end
    end
end