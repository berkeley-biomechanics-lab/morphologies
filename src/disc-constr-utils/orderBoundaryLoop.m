function Pord = orderBoundaryLoop(P, Fb)
% Order boundary loop by walking the edge chain from freeBoundary.
%
% INPUTS:
%   P  : [N×3] boundary vertex positions (Vsub, already reindexed)
%   Fb : [M×2] boundary edges from freeBoundary(TR) — each row is
%        [v1, v2] giving a directed boundary edge in the triangulation's
%        local vertex indices
%
% OUTPUT:
%   Pord : [N×3] boundary points in connected traversal order
%
% WHY NOT POLAR ANGLE SORT:
%   Polar angle sort (atan2) only produces a correct loop for convex
%   boundaries. Vertebral endplates are non-convex — polar angle sort
%   produces crossing edges and scrambled connectivity. Edge-chain
%   traversal follows the actual mesh topology and is correct for any
%   simply-connected boundary.

    assert(size(P,2) == 3, 'P must be N×3');

    if isempty(Fb)
        Pord = P;
        return;
    end

    N = size(P, 1);

    % ------------------------------------------------------------------
    % Build adjacency: for each vertex, which vertices does it connect to
    % via a boundary edge?
    % ------------------------------------------------------------------
    % Fb may contain both (a→b) and (b→a) for the same edge — keep unique
    % undirected pairs:
    edges = sort(Fb, 2);   % each row: [min, max]
    edges = unique(edges, 'rows');

    % Adjacency list:
    adj = cell(N, 1);
    for e = 1:size(edges,1)
        a = edges(e,1);
        b = edges(e,2);
        adj{a} = [adj{a}, b];
        adj{b} = [adj{b}, a];
    end

    % ------------------------------------------------------------------
    % Walk the chain starting from vertex 1
    % ------------------------------------------------------------------
    visited = false(N, 1);
    order   = zeros(N, 1);

    current  = 1;
    prev     = -1;
    order(1) = current;
    visited(current) = true;

    for step = 2:N
        neighbors = adj{current};

        % Pick the neighbor that isn't where we came from:
        next = -1;
        for nb = neighbors
            if nb ~= prev && ~visited(nb)
                next = nb;
                break;
            end
        end

        if next == -1
            % All neighbors visited or only one neighbor (boundary end)
            % — try any unvisited neighbor:
            for nb = neighbors
                if ~visited(nb)
                    next = nb;
                    break;
                end
            end
        end

        if next == -1
            % Loop closed early — truncate
            order = order(1:step-1);
            break;
        end

        order(step)   = next;
        visited(next) = true;
        prev    = current;
        current = next;
    end

    % Remove any trailing zeros:
    order = order(order > 0);

    Pord = P(order, :);
end

