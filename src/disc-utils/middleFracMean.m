function m = middleFracMean(v, f)
    % v : input vector (n x 1)
    % f : fraction between 0 and 1 (e.g., 0.5 for middle 50%)
    
    % Sort the vector
    v_sorted = sort(v);

    n = numel(v);
    k = round((1 - f) / 2 * n);   % number of elements to cut off from each side
    
    % Keep only middle f% of values
    v_middle = v_sorted(k+1 : n-k);

    % Compute mean
    m = mean(v_middle);
end
