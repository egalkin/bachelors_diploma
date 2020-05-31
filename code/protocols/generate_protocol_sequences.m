% Строим множество протокольных последовательностей по переданному
% представлению графового кода.

function protocol_sequneces = generate_protocol_sequences(H_conv, M)

    [m, n] = size(H_conv);

    H_matrix_length = max(max(H_conv(:, 1:2:end)));
    max_D_degree = max(max(H_conv(:, 2:2:end)));

    degree_distr = {};

    for i = 1:m 
        for j = 1:n
            if ~mod(j,2)
                cur_degree = H_conv(i, j);
                if cur_degree + 1 > length(degree_distr)
                    degree_distr{cur_degree + 1} = [i, H_conv(i,j-1)];
                else
                    degree_distr{cur_degree + 1} = [degree_distr{cur_degree + 1}, i, H_conv(i,j-1)];
                end
            end 
        end 
    end
    
    
    max_D_degree = max_D_degree + 1;
    
    
    protocol_sequence_row = zeros(m, H_matrix_length * max(max_D_degree, M));
    
    
    for degree = 1:max_D_degree
        cur_degree_indexes = degree_distr{degree};
        for idx = 1:2:length(cur_degree_indexes)
            i = cur_degree_indexes(idx);
            j = cur_degree_indexes(idx+1) + ((degree-1) * H_matrix_length);
            protocol_sequence_row(i,j) = 1;
        end
    end

    protocol_sequneces = [];
    
    for i = 0:M-1
        protocol_sequneces = [protocol_sequneces; circshift(protocol_sequence_row, i * H_matrix_length , 2)];
    end
    
end


     
     
     