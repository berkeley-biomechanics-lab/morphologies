function endplate = extractEndplate(mesh, Cdisc, Tdisc, which, cfg)
% Extract vertebral endplate using signed distance to disc plane.
%
% Boundary ordering uses edge-chain traversal (correct for non-convex
% boundaries). Jagged spike vertices are smoothed.
%
% NO winding enforcement is applied here — winding alignment between
% the two opposing endplates is handled once in
% getEndplatesFromAdjacentVertebrae, where both curves are available
% for comparison.
 
    V = mesh.TR.Points;
    F = mesh.TR.ConnectivityList;
 
    C = Cdisc(:)';
    n = Tdisc(:)';
    n = n / norm(n);
 
    % ---------------------------
    % Signed distance + slab
    % ---------------------------
    s               = (V - C) * n';
    proxyVertHeight = max(s) - min(s);
 
    alpha         = cfg.disc.alpha;
    slabThickness = alpha * proxyVertHeight;
    slabThickness = max(slabThickness, cfg.disc.minThickness);
    slabThickness = min(slabThickness, cfg.disc.maxThickness);
 
    switch lower(which)
        case "sup"
            keepV = s >= (max(s) - slabThickness);
        case "inf"
            keepV = s <= (min(s) + slabThickness);
        otherwise
            error("which must be 'inf' or 'sup'");
    end
 
    % ---------------------------
    % Keep faces fully inside slab, reindex
    % ---------------------------
    faceMask  = all(keepV(F), 2);
    Fsub      = F(faceMask, :);
    usedVerts = unique(Fsub(:));
    Vsub      = V(usedVerts, :);
 
    map = zeros(size(V,1), 1);
    map(usedVerts) = 1:numel(usedVerts);
    Fsub = map(Fsub);
 
    TR = triangulation(Fsub, Vsub);
 
    if hasHole(TR)
        warning("Subject %s, %s %s endplate has a hole! Tune cfg.disc.alpha", ...
                mesh.subjName, mesh.levelName, which);
    end
 
    % ---------------------------
    % Boundary extraction via edge-chain traversal
    % ---------------------------
    Fb             = freeBoundary(TR);
    boundaryVerts  = unique(Fb(:));
    Praw           = Vsub(boundaryVerts, :);
 
    % Remap Fb to Praw-local indices:
    remap          = zeros(size(Vsub,1), 1);
    remap(boundaryVerts) = 1:numel(boundaryVerts);
    FbLocal        = remap(Fb);
 
    Pord = orderBoundaryLoop(Praw, FbLocal);
    
    endplate.TR = TR;
    endplate.Pb = Pord;
end

