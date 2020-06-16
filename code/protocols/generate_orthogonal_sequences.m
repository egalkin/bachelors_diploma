function orthogonal_sequneces = generate_orthogonal_sequences(user_num)
    orthogonal_sequence_row = [1, zeros(1, user_num-1)];
    
    orthogonal_sequneces = [];
    
    for i = 0:user_num-1
        orthogonal_sequneces = [orthogonal_sequneces; circshift(orthogonal_sequence_row, i, 2)];
    end
end