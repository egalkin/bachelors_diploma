classdef User < handle
    properties
        message;
        current_active_block = 0;
        k;
        n;
        encoder = Encoder;
        added_blocks_num = 2;
    end
    methods
        function obj = User(k, n)
            if nargin == 2
                obj.k = k;
                obj.n = n;
            end
        end
        function generate_message(obj, blocks_num)
            obj.message = [randi([0, 1], 1 ,blocks_num * obj.k), zeros(1, obj.added_blocks_num * obj.k)];
        end
        function encoded_block = get_current_transmitted_block(obj)
            if obj.current_active_block < length(obj.message) / obj.k
                encoded_block = obj.encoder.encode(obj.message(obj.k * obj.current_active_block + 1:obj.k * obj.current_active_block + obj.k));
                obj.current_active_block = obj.current_active_block + 1;
            else 
                encoded_block = [];
            end
        end
        function msg = get_message(obj)
            msg = obj.message(1:end-obj.added_blocks_num * obj.k);
        end
        function reset_state(obj)
            obj.encoder.clear_state
            obj.current_active_block = 0;
        end
    end
end
