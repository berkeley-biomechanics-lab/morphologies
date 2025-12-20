function hasHole = hasHole(TR)
% Returns 'true' if the triangulation has >1 boundary component

    Fb = freeBoundary(TR);

    if isempty(Fb)
        hasHole = true;
        return;
    end

    % Build undirected boundary graph
    G = graph(Fb(:,1), Fb(:,2));

    % Vertex degrees
    deg = degree(G);

    % Keep only vertices that could belong to loops
    loopVerts = find(deg == 2);

    if numel(loopVerts) < 3
        hasHole = true;
        return;
    end

    % Induced subgraph of loop-like structure
    Gloop = subgraph(G, loopVerts);

    % Count loop components
    nLoops = max(conncomp(Gloop));

    % One loop = good endplate
    hasHole = (nLoops > 1);
end

