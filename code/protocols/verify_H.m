function is_verified = verify_H(H, J, K)
    is_verified = true;
      
    for i = 1:size(H,1)
        is_verified = is_verified && sum(H(i,:) == 1) == K;
        if ~is_verified
            return
        end
    end
    
    for i = 1:size(H,2)
        is_verified = is_verified && sum(H(:,i) == 1) == J;
        if ~is_verified
            return
        end
    end
end