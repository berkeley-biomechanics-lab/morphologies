function [hlat, xlat, xCoord, yCoord] = findHeightsLAT(x2D, y2D, x2D_b, y2D_b, X, Y, vq, nh)
    % Finds the height properties of the geometry along the lateral centroid axis

    % finding boundaries of 2D domain:
    [leftX, ~] = min(x2D); % minimum x-position in mesh grid
    [rightX, ~] = max(x2D); % maximum x-position in mesh grid
    latY = mean(y2D); % y-position of lat midline, midsection point as reference

    % characterizing 2D domain (unknown AP dimension):
    lateralX = linspace(leftX, rightX, nh);
    lateralY = linspace(latY, latY, nh);
    pgon = polyshape(x2D_b, y2D_b); % x2D_b, y2D_b: polygon vertices
    inPgon = isinterior(pgon, lateralX, lateralY); % lateralX, lateralY: query points
    xdomain = lateralX(inPgon); % domain of x-coordinates inside boundary @ y = latY
    lX = min(xdomain); % left lateral x-position
    rX = max(xdomain); % right lateral x-position

    % characterizing 2D domain (known AP dimension):
    xCoord = [lX, rX]; % x-coordinates of lateral line
    yCoord = [latY, latY]; % y-coordinates of lateral line
    [latXheight, latYheight] = meshgrid(linspace(lX, rX, nh), lateralY); % middle lateral meshgrid
    I = interp2(X, Y, vq, latXheight, latYheight); % interpolating heights along lateral line
    [~, ia, ~] = unique(I);
    ia = sort(ia);
    hlat = I(ia);
    xlat = unique(latXheight(ia));
    hlat = hlat(~isnan(hlat));
    xlat = xlat(~isnan(hlat));

    % interpolating AP heights and positions to a fixed size of nh:
    dx = diff(hlat);
    dy = diff(xlat);
    distances = sqrt(dx.^2 + dy.^2); % calculating distances between consecutive points
    arc_length = [0; cumsum(distances)]; % cumulative arc length
    arc_length_new = linspace(0, arc_length(end), nh); % new equally spaced arc-length values
    hlat = interp1(arc_length, hlat, arc_length_new, 'linear')';
    xlat = interp1(arc_length, xlat, arc_length_new, 'linear')';
end


