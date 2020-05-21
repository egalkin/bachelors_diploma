
function combs = multicombination(values, k)
    if length(values)==1 
        n = values;
        combs = nchoosek(n+k-1,k);
    else
        n = length(values);
        combs = nchoosek(1:n+k-1,k) - (0:k-1);
        combs = reshape(values(combs),[],k);
    end
end