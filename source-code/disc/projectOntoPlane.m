function proj = projectOntoPlane(pts, ppt, n)
    % pts: matrix where each row represents a point to be projected
    % ppt: A point on the plane
    % n: The normal vector of the plane 
    
    sz = size(pts);
    norms = repmat(n, sz(1), 1); % vertically stacking copies of n vector
    proj = pts - dot(pts - ppt, norms, 2) .* n;
end

