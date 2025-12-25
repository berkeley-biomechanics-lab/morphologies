function [Px, Py, Pz] = makeAllPlanes(sx, sy, sz, bbox)
% Construct triangulated slicing planes for x, y, z axes
%
% Inputs:
%   sx, sy, sz : slice locations along x, y, z (1×numSlices)
%   bbox       : 3×2 bounding box [xmin xmax; ymin ymax; zmin zmax]
%
% Outputs:
%   Px, Py, Pz : struct arrays with fields .vertices, .faces
%                suitable for SurfaceIntersection()

    numSlices = numel(sx);

    % Preallocate plane arrays
    Px(numSlices) = struct('vertices', [], 'faces', []);
    Py = Px;
    Pz = Px;

    % Bounding extents
    xmin = bbox(1,1); xmax = bbox(1,2);
    ymin = bbox(2,1); ymax = bbox(2,2);
    zmin = bbox(3,1); zmax = bbox(3,2);

    % --- X slices (YZ planes) ---
    for k = 1:numSlices
        x = sx(k);
        V = [
            x ymin zmin
            x ymax zmin
            x ymax zmax
            x ymin zmax
        ];
        F = [1 2 3; 1 3 4];
        Px(k).vertices = V;
        Px(k).faces    = F;
    end

    % --- Y slices (XZ planes) ---
    for k = 1:numSlices
        y = sy(k);
        V = [
            xmin y zmin
            xmax y zmin
            xmax y zmax
            xmin y zmax
        ];
        F = [1 2 3; 1 3 4];
        Py(k).vertices = V;
        Py(k).faces    = F;
    end

    % --- Z slices (XY planes) ---
    for k = 1:numSlices
        z = sz(k);
        V = [
            xmin ymin z
            xmax ymin z
            xmax ymax z
            xmin ymax z
        ];
        F = [1 2 3; 1 3 4];
        Pz(k).vertices = V;
        Pz(k).faces    = F;
    end
end

