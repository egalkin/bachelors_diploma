function orthogonal_sequneces = generate_orthogonal_sequences(P, T)
    orthogonal_sequence_row = [ones(1, floor(T/P)), zeros(1, T - floor(T/P))];
    
    orthogonal_sequneces = [];
    
    for i = 0:P-1
        orthogonal_sequneces = [orthogonal_sequneces; circshift(orthogonal_sequence_row, i, 2)];
    end
end