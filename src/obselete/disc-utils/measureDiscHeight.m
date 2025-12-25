%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the inferior and superior point cloud distributions, this program
% discretizes the disc goemetry across the 2D XY plane and measures 
% the height distribution
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc

% script variables:
varsbefore = who;

%% Determining inferior/superior disc point clouds

% transforming disc points to rotated coordinated system:
co = mean([supPoints; infPoints]);
c = (R * co')'; % position of projection plane
supPoints = (R * supPoints')';
infPoints = (R * infPoints')';

%% Extracting heights
% Using the inferor or superior surface as the reference distance surface, 
% the height is found by projecting inferior + superior points onto a 
% singular plane, bounding the points via the reference surface, and selecting
% which inferior + superior points best project onto one another by 
% minimizing the 2D projected distance

% extraction variables:
axisH = [0,0,1]; % height axis (normal vector of surface to be projected upon)
refSurface = 'superior'; % height is found by projecting these surface points to the opposite surface points
useBoundary = true; % whether or not to use the opposite surface to bound measurement selection

% extracting heights from superior and inferior surfaces:
[heights, refProj, refPoints, r] = extractHeights(axisH, c, supPoints, infPoints, refSurface, useBoundary);

%% Extrapolating XY domain

% 3D XY coordinates associated with heights:
xy3Dheights = refProj;

% transforming XY into 2D:
p2D = [1 0 0;0 1 0]'; % 3D --> 2D projection matrix
xy2Dheights = xy3Dheights * p2D; % 2D XY coordinates associated with heights

% finding boundary around 2D data:
x2D = xy2Dheights(:,1);
y2D = xy2Dheights(:,2);
c2D = mean([x2D, y2D]); % centroid of region
c2Dx = c2D(1); % x-coordinate of centroid
c2Dy = c2D(2); % y-coordinate of centroid
sf = 0.5; % shrink factor, 0 --> convex hull and 1 --> compact boundary
[Ib, ~] = boundary(x2D, y2D, sf);
x2D_b = x2D(Ib);
y2D_b = y2D(Ib);

% scaling boundary about centroid:
s = 1; % boundary scaling factor --> s = 1 (full boundary), s < 1 (tighter boundary)
if s ~= 1
    x2D_b = c2Dx + s * (x2D_b - c2Dx);
    y2D_b = c2Dy + s * (y2D_b - c2Dy);
    kx = find((x2D >= min(x2D_b)) & (x2D <= max(x2D_b))); % x-coords inside x-boundary
    ky = find((y2D >= min(y2D_b)) & (y2D <= max(y2D_b))); % y-coords inside y-boundary
    kI = intersect(kx, ky);  % (x,y)-coords inside (x,y)-boundary
    x2D = x2D(kI);
    y2D = y2D(kI);
    c2D = mean([x2D, y2D]); % centroid of region
    c2Dx = c2D(1); % x-coordinate of centroid
    c2Dy = c2D(2); % y-coordinate of centroid
    heights = heights(kI)';
end

% discretizing XY domain:
x2dmin = min(x2D_b);
x2dmax = max(x2D_b);
x2diff = x2dmax - x2dmin;
y2dmin = min(y2D_b);
y2dmax = max(y2D_b);
y2diff = y2dmax - y2dmin;
xx = x2dmin:x2diff/nh:x2dmax;
yy = y2dmin:y2diff/nh:y2dmax;

% characterizing 2D domain:
[X, Y] = meshgrid(xx, yy); % describes 2D domain with scaled vertebrae boundaries as grid boundaries
vq = griddata(x2D, y2D, heights', X, Y);
inside = inpolygon(X, Y, x2D_b, y2D_b);
vq(~inside) = NaN;

%% Calculating and processing heights along AP positions

% finding anterior-posterior height properties:
[hAP, yAP, xCoordAP, yCoordAP] = findHeightsAP(x2D, y2D, x2D_b, y2D_b, X, Y, vq, nh);
yAP = yAP - min(yAP); % normalize to start AP position measurement @ 0
apWidth = max(yAP) - min(yAP);

% getting AP height distribution mean:
hAPmean = mean(hAP);

% getting AP height peaks:
pksAP = double.empty;
proms = logspace(1, -3, 100);
o = 1; % MinPeakProminence counter
while isempty(pksAP) || numel(pksAP) ~= 1
    [pksAP, locsAP] = findpeaks(hAP, yAP, 'NPeaks', 1, 'MinPeakProminence', proms(o));
    o = o + 1;
end
disp("Peak AP disc height: " + string(pksAP))

%% Calculating and processing heights along lateral positions

% finding lateral height properties:
[hlat, xlat, xCoordlat, yCoordlat] = findHeightsLAT(x2D, y2D, x2D_b, y2D_b, X, Y, vq, nh);
xlat = xlat - min(xlat); % normalize to start lateral position measurement @ 0
latWidth = max(xlat) - min(xlat);

% getting lateral height distribution mean:
hlatmean = mean(hlat);

% getting lateral height peaks:
pksL = double.empty;
proms = logspace(1, -3, 100);
p = 1; % MinPeakProminence counter
while isempty(pksL) || numel(pksL) ~= 1
    [pksL, locsL] = findpeaks(hlat, xlat, 'NPeaks', 1, 'MinPeakProminence', proms(p));
    p = p + 1;
end
disp("Peak AP lateral height: " + string(pksL))

%% Plotting vertebral height distribution

makeplot = true;
makenewfig = false;
plotHeights = false;
if makeplot
    figtitle = string(subj) + ', ' + string(lvl);
    if makenewfig
        figure;
    elseif ~exist('hfig','var') || ~ishandle(hfig)
        hfig = figure;
        figure(hfig);
    else
        set(0, 'CurrentFigure', hfig)
        figure(hfig);
    end
    sgtitle('Height Measurements')
    
    % 2D height distribution
    subplot(3,3,[1 5]);
    cla
    hold on
    lvls = 100;
    contourf(X, Y, vq, lvls, 'LineStyle', 'none');
    line(xCoordAP, yCoordAP, 'Color', 'black', 'LineStyle', '--')
    line(xCoordlat, yCoordlat, 'Color', 'black', 'LineStyle', '--')
    c = colorbar;
    c.Limits = [min(heights) max(heights)];
    c.Label.String = 'height [mm]';
    plot(x2D_b, y2D_b, 'r', 'linewidth', 3);
    scatter(c2D(:,1), c2D(:,2), '*k')
    xlim([min(xy2Dheights(:,1)) max(xy2Dheights(:,1))])
    ylim([min(xy2Dheights(:,2)) max(xy2Dheights(:,2))])
    xlabel('X [mm]');
    ylabel('Y [mm]');
    title('2D height distribution for ' + figtitle)
    drawnow
    
    % raw anterior-posterior height distribution
    subplot(3,3,[3 6]);
    cla
    hold on
    plot(hAP, yAP)
    xlim([min(hAP) max(hAP)])
    ylim([min(yAP) max(yAP)])
    xline(hAPmean, '--r')
    plot(pksAP, locsAP, 'b*')
    xlabel('sup-inf height [mm]')
    ylabel('position along AP [mm]')
    title('Raw AP height distribution')
    drawnow

    % raw lateral height distribution
    subplot(3,3,[7 8]);
    cla
    hold on
    plot(xlat, hlat)
    xlim([min(xlat) max(xlat)])
    ylim([min(hlat) max(hlat)])
    yline(hlatmean, '--r')
    plot(locsL, pksL, 'b*')
    xlabel('position along lateral [mm]')
    ylabel('lateral height [mm]')
    title('Raw lateral height distribution')
    drawnow

    % superior and inferior surfaces
    subplot(3,3,9);
    cla
    hold on
    scatter3(P_disc(:,1), P_disc(:,2), P_disc(:,3), 'b')
    scatter3(Pt_disc(:,1), Pt_disc(:,2), Pt_disc(:,3), 'r')
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
    title('Original + transformed disc goemetry (sagittal view)')
    view(90, 0) % YZ plane
    legend('pre', 'post')
    drawnow
end

%% MATLAB cleanup

% deleting everything except areas and Z:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'hAP', 'yAP', 'hfig'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
