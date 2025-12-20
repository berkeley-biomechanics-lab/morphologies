function discTR = stitchDisc(Pk, TRs, TRi)
% Stitches lofted disc boundary curves into a watertight surface
%
% Inputs:
%   Pk  - cell array of size K, each [Nb x 3]
%   TRs - superior endplate triangulation
%   TRi - inferior endplate triangulation
%
% Output:
%   discTR - triangulation of entire disc surface

    K  = numel(Pk);
    nRings = size(Pk{1},1);

    % -------------------------------------------------
    % 1. Stack all boundary vertices
    % -------------------------------------------------
    V = zeros(K*nRings,3);
    for k = 1:K
        idx = (k-1)*nRings + (1:nRings);
        V(idx,:) = Pk{k};
    end

    % -------------------------------------------------
    % 2. Side-wall faces
    % -------------------------------------------------
    Fside = [];

    for k = 1:(K-1)
        for i = 1:nRings
            i2 = mod(i,nRings) + 1;

            v1 = (k-1)*nRings + i;
            v2 = (k-1)*nRings + i2;
            v3 = k*nRings     + i;
            v4 = k*nRings     + i2;

            % Two triangles per quad
            Fside(end+1,:) = [v1 v3 v2];
            Fside(end+1,:) = [v2 v3 v4];
        end
    end

    % -------------------------------------------------
    % 3. Merge inferior endplate
    % -------------------------------------------------
    Vi = TRi.Points;
    Fi = TRi.ConnectivityList + size(V,1);

    V = [V; Vi];

    % -------------------------------------------------
    % 4. Merge superior endplate
    % -------------------------------------------------
    Vs = TRs.Points;
    Fs = TRs.ConnectivityList + size(V,1);

    V = [V; Vs];

    % -------------------------------------------------
    % 5. Combine all faces
    % -------------------------------------------------
    F = [Fside; Fi; Fs];

    discTR = triangulation(F,V);
end

