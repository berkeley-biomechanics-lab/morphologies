function widths = midlineWidths(poly, axes2D)
% Widths of a polyshape measured along lines through its centroid

    arguments
        poly polyshape
        axes2D (2,2) double
    end

    % Normalize axes
    u1 = axes2D(:,1) / norm(axes2D(:,1));
    u2 = axes2D(:,2) / norm(axes2D(:,2));

    if abs(dot(u1,u2)) > 1e-6
        error('Axes must be orthogonal.');
    end

    [Cx, Cy] = centroid(poly);
    V = poly.Vertices;

    widths.w = zeros(1,2);
    widths.endpoints = cell(1,2);
    widths.axes = [u1 u2];

    for i = 1:2
        u = widths.axes(:,i);

        % Large line through centroid
        t = max(range(V)) * 2;
        if isempty(t)
            continue;
        end

        P1 = [Cx, Cy] - t*u';
        P2 = [Cx, Cy] + t*u';

        % Intersect polygon with line segment
        [in,~] = intersect(poly, [P1; P2]);

        if isempty(in)
            widths.w(i) = 0;
            widths.endpoints{i} = [NaN NaN; NaN NaN];
            continue
        end

        % Sort intersection points along axis
        s = in * u;
        [~,idx] = sort(s);

        pmin = in(idx(1),:);
        pmax = in(idx(end),:);

        widths.w(i) = norm(pmax - pmin);
        widths.endpoints{i} = [pmin; pmax];
    end
end

