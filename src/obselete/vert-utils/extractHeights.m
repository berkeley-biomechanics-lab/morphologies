function [heights, refProj, refPoints, r] = extractHeights(axisH, c, supPoints, infPoints, refSurface, useBoundary)
    % Using the inferor or superior surface as the reference distance surface, 
    % the height is found by projecting inferior + superior points onto a 
    % singular plane, bounding the points via the reference surface, and selecting
    % which inferior + superior points best project onto one another by 
    % minimizing the 2D projected distance

    supProj = projectOntoPlane(supPoints, c, axisH); % size: [M, 3]
    infProj = projectOntoPlane(infPoints, c, axisH);  % size: [N, 3]
    
    % finding boundary around 2D projected data:
    sup2D = supProj(:,1:2); % getting 2D projected superior coordinates
    sup2Dx = sup2D(:,1); % x-coordinates of projected superior coordinates
    sup2Dy = sup2D(:,2); % y-coordinates of projected superior coordinates
    inf2D = infProj(:,1:2); % getting 2D projected inferior coordinates
    inf2Dx = inf2D(:,1); % x-coordinates of projected inferior coordinates
    inf2Dy = inf2D(:,2); % y-coordinates of projected inferior coordinates
    
    sf = 1; % shrink factor, 0 --> convex hull and 1 --> compact boundary
    if strcmp(refSurface, 'superior')
        D = pdist2(supProj, infProj); % computing distance matrix: M x N
    
        % for each supPoint, find closest point in infPoints that is inside the
        % reference surface:
        [~, idx_min] = min(D, [], 2);  % idx_min is M x 1
        closestPoints = infPoints(idx_min,:); % M x 3
        if useBoundary
            % determining whether the opposite surface's 2D boundary includes the
            % reference surface points:
            [Ib, ~] = boundary(inf2Dx, inf2Dy, sf); % 2D boundary of inferior coordinates
            inf2Dx_b = inf2Dx(Ib); % x-coordinates of 2D inferior boundary
            inf2Dy_b = inf2Dy(Ib); % y-coordinates of 2D inferior boundary
            insideRefSurface = inpolygon(sup2Dx, sup2Dy, inf2Dx_b, inf2Dy_b); % M x 1, (sup2Dx, sup2Dy) = query points
    
            % re-indexing points:
            closestPoints = closestPoints(insideRefSurface,:);
            refPoints = supPoints(insideRefSurface,:);
            refProj = supProj(insideRefSurface,:);
        else 
            refPoints = supPoints;
            refProj = supProj;
        end
        r = closestPoints - refPoints; % distance vectors
    elseif strcmp(refSurface, 'inferior')
        D = pdist2(infProj, supProj); % computing distance matrix: M x N
    
        % for each infPoint, find closest point in supPoints that is inside the
        % reference surface:
        [~, idx_min] = min(D, [], 2);  % idx_min is M x 1
        closestPoints = supPoints(idx_min,:); % M x 3
        if useBoundary
            % determining whether the opposite surface's 2D boundary includes the
            % reference surface points:
            [Ib, ~] = boundary(sup2Dx, sup2Dy, sf); % 2D boundary of superior coordinates
            sup2Dx_b = sup2Dx(Ib); % x-coordinates of 2D superior boundary
            sup2Dy_b = sup2Dy(Ib); % y-coordinates of 2D superior boundary
            insideRefSurface = inpolygon(inf2Dx, inf2Dy, sup2Dx_b, sup2Dy_b);  % M x 1, (inf2Dx, inf2Dy) = query points
    
            % re-indexing points:
            closestPoints = closestPoints(insideRefSurface,:);
            refPoints = infPoints(insideRefSurface,:);
            refProj = infProj(insideRefSurface,:);
        else 
            refPoints = infPoints;
            refProj = infProj;
        end
        r = closestPoints - infPoints; % distance vectors
    else
        disp('Inappropriate reference surface has been chosen!')
        quit
    end
    
    % computing distance norms:
    heights = vecnorm(r,2,2)'; % height measurements  
end


