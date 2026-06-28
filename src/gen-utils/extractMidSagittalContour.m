function loops = extractMidSagittalContour(TR, xMid)
% Extract mid-sagittal contour using exact plane-mesh intersection
% via SurfaceIntersection (Möller algorithm).
%
% INPUTS:
%   TR   : triangulation object (passed as struct to bypass freeBoundary)
%   xMid : X coordinate of the sagittal cutting plane
%
% OUTPUT:
%   loops : cell array of [Ni x 2] (Y,Z) ordered contour segments.
%           Each cell is one disconnected loop/chain.
%           Returns {} if no intersection found.

    pts = TR.Points;

    margin = 20;
    yMin = min(pts(:,2)) - margin;  yMax = max(pts(:,2)) + margin;
    zMin = min(pts(:,3)) - margin;  zMax = max(pts(:,3)) + margin;

    % Pass as STRUCT (not triangulation object) to bypass the freeBoundary
    % call inside SurfaceIntersection — uses all faces regardless of
    % watertightness:
    surface1.vertices = pts;
    surface1.faces    = TR.ConnectivityList;
    surface2.vertices = [xMid, yMin, zMin;
                         xMid, yMax, zMin;
                         xMid, yMax, zMax;
                         xMid, yMin, zMax];
    surface2.faces    = [1 2 3; 1 3 4];

    [~, intSurface] = SurfaceIntersection(surface1, surface2);

    if isempty(intSurface.edges) || isempty(intSurface.vertices)
        loops = {};
        return;
    end

    % Chain edge segments into ordered loops:
    loops = chainEdgeSegments(intSurface.edges, intSurface.vertices);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL: chainEdgeSegments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loops = chainEdgeSegments(segs, verts)
% Chain unordered edge segments into one or more ordered polylines.
%
% INPUTS:
%   segs  : [M x 2] edge index pairs from SurfaceIntersection
%   verts : [N x 3] vertex positions
%
% OUTPUT:
%   loops : cell array, each entry [Li x 2] (Y,Z) coords of one chain

    if isempty(segs)
        loops = {};
        return;
    end

    nSeg = size(segs, 1);
    used = false(nSeg, 1);
    loops = {};

    while any(~used)
        % Start a new chain from the first unused segment:
        startIdx = find(~used, 1);
        chain    = [segs(startIdx,1), segs(startIdx,2)];
        used(startIdx) = true;

        % Extend the chain forward:
        growing = true;
        while growing
            currentVert = chain(end);
            growing = false;
            for s = 1:nSeg
                if used(s), continue; end
                if segs(s,1) == currentVert
                    chain(end+1) = segs(s,2); %#ok<AGROW>
                    used(s) = true;
                    growing = true;
                    break;
                elseif segs(s,2) == currentVert
                    chain(end+1) = segs(s,1); %#ok<AGROW>
                    used(s) = true;
                    growing = true;
                    break;
                end
            end
        end

        % Only keep chains with enough points to be meaningful:
        if numel(chain) >= 3
            xyz = verts(chain, :);
            loops{end+1} = xyz(:, 2:3);   % (Y,Z) only %#ok<AGROW>
        end
    end
end

