function adj = buildAdjacency(E, nV)

    adj = cell(nV,1);
    for i = 1:size(E,1)
        a = E(i,1);
        b = E(i,2);
        adj{a}(end+1) = b;
        adj{b}(end+1) = a;
    end
end

