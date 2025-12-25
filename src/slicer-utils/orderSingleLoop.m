function loop = orderSingleLoop(adj, loopVerts)

    % Start anywhere
    start = loopVerts(1);
    loop = start;

    prev = -1;
    curr = start;

    while true
        nbrs = adj{curr};
        % pick neighbor not equal to previous
        next = nbrs(nbrs ~= prev);

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

