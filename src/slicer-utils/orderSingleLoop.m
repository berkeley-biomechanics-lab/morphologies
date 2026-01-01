function loop = orderSingleLoop(adj, loopVerts)

    assert(all(ismember(loopVerts, unique([adj{loopVerts}]))), "Loop error detected!")

    % Start anywhere
    start = loopVerts(1);
    loop = start;

    prev = -1;
    curr = start;

    while true
        nbrs = adj{curr};

        % pick neighbor not equal to previous and curr:
        next = nbrs(nbrs ~= prev); next = next(next ~= curr);

        if isempty(next)
            break
        end

        next = next(1);

        if next == start
            break
        end

        loop(end+1) = next;
        prev = curr;
        curr = next;
    end
end

