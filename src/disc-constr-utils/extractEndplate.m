function endplate = extractEndplate(mesh, Cdisc, Tdisc, which, cfg)
% Extract vertebral endplate using signed distance to disc plane
%
% INPUTS
%   mesh.TR    : triangulation
%   Cdisc      : [1×3] disc center
%   Tdisc      : [1×3] disc tangent (SI axis, unit)
%   which      : 'sup' or 'inf'
%   cfg.disc.endplateThickness   (mm)
%
% OUTPUT
%   endplate.TR

    % ---------------------------
    % Unpack
    % ---------------------------
    V = mesh.TR.Points;
    F = mesh.TR.ConnectivityList;

    C = Cdisc(:)';
    n = Tdisc(:)';
    n = n / norm(n);

    % ---------------------------
    % Signed distance
    % ---------------------------
    s = (V - C) * n';
    proxyVertHeight = max(s) - min(s);

    % ---------------------------
    % Define slab
    % ---------------------------
    alpha = cfg.disc.alpha;
    minThickness = cfg.disc.minThickness;
    maxThickness = cfg.disc.maxThickness;
    slabThickness = alpha * proxyVertHeight;
    
    % Applying slab thickness limits:
    slabThickness = max(slabThickness, minThickness);
    slabThickness = min(slabThickness, maxThickness);
    switch lower(which)
        case "sup"
            sMax = max(s);
            keepV = s >= (sMax - slabThickness);
        case "inf"
            sMin = min(s);
            keepV = s <= (sMin + slabThickness);
        otherwise
            error("which must be 'inf' or 'sup'");    
    end

    % ---------------------------------
    % Keep faces fully inside slab
    % ---------------------------------
    % NOTE: exported endplate surface will not be retriangulated! Once the
    % desired s-values are chosen, the vertebra faces assocated with each
    % s-value is identified via 'keepV' and stored in 'faceMask'. 
    % Subsequently, the associated vertices will be stored in 'Vsub' and
    % a triangulation object will be made:
    faceMask = all(keepV(F), 2);
    Fsub = F(faceMask, :);

    % ---------------------------
    % Reindex vertices
    % ---------------------------
    usedVerts = unique(Fsub(:));
    Vsub = V(usedVerts, :);

    map = zeros(size(V,1),1);
    map(usedVerts) = 1:numel(usedVerts);
    Fsub = map(Fsub);

    TR = triangulation(Fsub, Vsub);

    % Getting holes information:
    endplateHasHole = hasHole(TR);

    % There are a number of ways to check the quality of the extracted
    % endplate surface. For simplicity, if # of holes > 0, then this
    % indicates the endplate has a hole and requires a different
    % configuration setting. Use this warning to tune the 'cfg.disc.alpha'
    % parameter:
    if endplateHasHole
        warning("Subject %s, %s %s endplate has a hole! Tune cfg.disc.alpha", ...
                    mesh.subjName, mesh.levelName, which);
    end

    % ---------------------------
    % Boundary extraction
    % ---------------------------
    Fb = freeBoundary(TR); % boundary edges
    Praw = Vsub(unique(Fb(:)),:);
    
    % ---------------------------
    % Order boundary points
    % ---------------------------
    Pord = orderBoundaryLoop(Praw); % re-ordering boundary loop

    % ---------------------------
    % Output
    % ---------------------------
    endplate.TR = TR;
    endplate.Pb = Pord; % (ordered) boundary points
end

