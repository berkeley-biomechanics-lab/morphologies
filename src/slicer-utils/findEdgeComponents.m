function components = findEdgeComponents(E)

    G = graph(E(:,1), E(:,2));
    bins = conncomp(G);

    components = cell(max(bins),1);
    for k = 1:max(bins)
        components{k} = find(bins == k);
    end
end

