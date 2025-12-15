function endplate = extractEndplate(mesh, which, pct)
% extracting the endplate datapoints from the "superior" and "inferior"
% vertebral meshes. 

    V = mesh.TR.Points;
    F = mesh.TR.ConnectivityList;
    c = mesh.centroid(:)';
    n = mesh.frame.SI(:)';   % SI unit vector

    % Project vertices onto SI axis
    s = (V-c) * n';

    switch lower(which)
        case 'sup'
            sCut = prctile(s, 100 - pct);
            idx = s >= sCut;
        case 'inf'
            sCut = prctile(s, pct);
            idx = s <= sCut;
        otherwise
            error('which must be "sup" or "inf"');
    end

    % Keep faces whose vertices all lie in the slab
    faceMask = all(idx(F), 2);

    % Build endplate mesh
    endplate.Points = V(idx,:);
    endplate.ConnectivityList = F(faceMask,:);
end

