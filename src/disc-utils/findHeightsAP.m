function [hAP, yAP, xCoord, yCoord] = findHeightsAP(x2D, y2D, x2D_b, y2D_b, X, Y, vq, nh)
    % Finds the height properties of the geometry along the AP centroid axis

    % finding boundaries of 2D domain:
    [anteriorY, ~] = min(y2D); % minimum y-position in mesh grid
    [posteriorY, ~] = max(y2D); % maximum y-position in mesh grid
    apX = mean(x2D); % x-position of AP midline, midsection point as reference

    % characterizing 2D domain (unknown AP dimension):
    antpostX = linspace(apX, apX, nh);
    antpostY = linspace(anteriorY, posteriorY, nh);
    pgon = polyshape(x2D_b, y2D_b); % x2D_b, y2D_b: polygon vertices
    inPgon = isinterior(pgon, antpostX, antpostY); % antpostX, antpostY: query points
    ydomain = antpostY(inPgon); % domain of y-coordinates inside boundary @ x = apX
    aY = min(ydomain); % anterior AP y-position
    pY = max(ydomain); % posterior AP y-position

    % characterizing 2D domain (known AP dimension):
    xCoord = [apX, apX]; % x-coordinates of AP line
    yCoord = [aY, pY]; % y-coordinates of AP line
    [apXheight, apYheight] = meshgrid(antpostX, linspace(aY, pY, nh)); % middle AP meshgrid
    I = interp2(X, Y, vq, apXheight, apYheight); % interpolating heights along AP line
    [~, ia, ~] = unique(I);
    ia = sort(ia);
    hAP = I(ia);
    yAP = unique(apYheight(ia));
    hAP = hAP(~isnan(hAP));
    yAP = yAP(~isnan(hAP));

    % interpolating AP heights and positions to a fixed size of nh:
    dx = diff(hAP);
    dy = diff(yAP);
    distances = sqrt(dx.^2 + dy.^2); % calculating distances between consecutive points
    arc_length = [0; cumsum(distances)]; % cumulative arc length
    arc_length_new = linspace(0, arc_length(end), nh); % new equally spaced arc-length values
    hAP = interp1(arc_length, hAP, arc_length_new, 'linear')';
    yAP = interp1(arc_length, yAP, arc_length_new, 'linear')';
end


