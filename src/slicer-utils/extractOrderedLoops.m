function loops = extractOrderedLoops(V, E)

    nV = size(V,1);
    adj = buildAdjacency(E, nV);
    components = findEdgeComponents(E);

    loops = cell(numel(components),1);

    for k = 1:numel(components)
        loops{k} = orderSingleLoop(adj, components{k});
    end
end

