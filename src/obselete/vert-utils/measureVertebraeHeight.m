%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the inferior and superior point cloud distributions, this program
% discretizes the vertebral goemetry across the 2D XY plane and measures 
% the height distribution
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc

% script variables:
varsbefore = who;

%% Determining equation of inferior/superior bonudary planes

% choosing three vertices and calculate two vectors, for each plane:
infv1 = infPV(2,:) - infPV(1,:);
infv2 = infPV(3,:) - infPV(1,:);
supv1 = supPV(2,:) - supPV(1,:);
supv2 = supPV(3,:) - supPV(1,:);

% calculating normal vector, for each plane:
infn = cross(infv1, infv2);
supn = cross(supv1, supv2);

% choosing vertex and finding equation, for each plane:
Dinf = -infn * infPV(1,:)';
Dsup = -supn * supPV(1,:)';
pinf = [infn, Dinf]';
psup = [supn, Dsup]';

% verifying the fourth vertex, for each plane:
tol = 1e-8;
inf4 = infPV(4,:);
sup4 = supPV(4,:);
if abs(pinf(1)*inf4(1) + pinf(2)*inf4(2) + pinf(3)*inf4(3) + pinf(4)) < tol
    % do nothing
else
    disp('The fourth inferior vertex does not satisfy the equation.');
end
if abs(psup(1)*sup4(1) + psup(2)*sup4(2) + psup(3)*sup4(3) + psup(4)) < tol
    % do nothing
else
    disp('The fourth superior vertex does not satisfy the equation.');
end

%% Determining inferior/superior vertebral surfaces

% calculating z-coordinates on inferior/superior planes:
zOnInfPlane = (-pinf(1)*Pt(:,1) - pinf(2)*Pt(:,2) - pinf(4)) ./ pinf(3);
zOnSupPlane = (-psup(1)*Pt(:,1) - psup(2)*Pt(:,2) - psup(4)) ./ psup(3);

% comparing z-coordinates to boundary planes:
belowInfPlane = Pt(:,3) <= zOnInfPlane;
aboveSupPlane = Pt(:,3) >= zOnSupPlane;

% partitioning inferior/superior surfaces:
infPoints = Pt(belowInfPlane,:);
supPoints = Pt(aboveSupPlane,:);

%% Finding surface areas of inferior/superior vertebral surfaces

% contructing point clouds:
ptCloudInf = pointCloud(infPoints);
ptCloudSup = pointCloud(supPoints);

% estimating normals:
normalsInf = pcnormals(ptCloudInf, 20);  % 20 neighbors for smoother results
ptCloudInf.Normal = normalsInf;
normalsSup = pcnormals(ptCloudSup, 20);  % 20 neighbors for smoother results
ptCloudSup.Normal = normalsSup;

% reconstructing the surface mesh:
[meshInf, ~] = pc2surfacemesh(ptCloudInf, "ball-pivot");
[meshSup, ~] = pc2surfacemesh(ptCloudSup, "ball-pivot");

% computing normals of the surface meshes (creates VertexNormals + FaceNormals feature inside each mesh):
computeNormals(meshInf);
computeNormals(meshSup);

% obtaining averaged normal vector for each surface mesh (using the
% vertices as a reference):
normInf = mean(meshInf.VertexNormals, 1);
normSup = mean(meshSup.VertexNormals, 1);

% computing inferior + superior surface area:
VInf = meshInf.Vertices;
VSup = meshSup.Vertices;
FInf = meshInf.Faces;
FSup = meshSup.Faces;
areaInf = 0;
areaSup = 0;
for i = 1:size(FInf, 1)
    tri = VInf(FInf(i,:), :);
    areaInf = areaInf + 0.5 * norm(cross(tri(2,:) - tri(1,:), tri(3,:) - tri(1,:)));
end
for i = 1:size(FSup, 1)
    tri = VSup(FSup(i,:), :);
    areaSup = areaSup + 0.5 * norm(cross(tri(2,:) - tri(1,:), tri(3,:) - tri(1,:)));
end
fprintf("Inferior Surface area = %.2f mm²\n", areaInf);
fprintf("Superior Surface area = %.2f mm²\n", areaSup);
fprintf("Total Surface area = %.2f mm²\n", surfareas{ii}{jj});

% plotting:
makeplot = false; % figures will not dock, I recommend keeping this turned off unless visualization is desired
if makeplot
    surfaceMeshShow(meshInf, Title="Inferior Surface Mesh", BackgroundColor="white");
    surfaceMeshShow(meshSup, Title="Superior Surface Mesh", BackgroundColor="white");
end

%% Extracting heights
% Using the inferor or superior surface as the reference distance surface, 
% the height is found by projecting inferior + superior points onto a 
% singular plane, bounding the points via the reference surface, and selecting
% which inferior + superior points best project onto one another by 
% minimizing the 2D projected distance

% extraction variables:
axisH = [0,0,1]; % height axis (normal vector of surface to be projected upon)
c = mean(Pt); % position of projection plane
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
while isempty(pksAP) || numel(pksAP) ~= 2
    [pksAP, locsAP] = findpeaks(hAP, yAP, 'NPeaks', 2, 'MinPeakProminence', proms(o));
    o = o + 1;
end
[yA, IA] = min(locsAP);
[yP, IP] = max(locsAP);
hA = pksAP(IA);
hP = pksAP(IP);
apratio = hA/hP;
disp("Anterior-posterior height ratio: " + string(apratio))

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
while isempty(pksL) || numel(pksL) ~= 2
    [pksL, locsL] = findpeaks(hlat, xlat, 'NPeaks', 2, 'MinPeakProminence', proms(p));
    p = p + 1;
end
[yL, IL] = min(locsL);
[yR, IR] = max(locsL);
hL = pksL(IL);
hR = pksL(IR);
lrratio = hL/hR;
disp("Left-right height ratio: " + string(lrratio))

%% Getting original coordinates (for plotting) using intermediate values

% getting previously determined values:
Ricp = Ricps{ii}{jj};
Ticp = Ticps{ii}{jj};
c1 = c1s{ii}{jj};
c2 = c2s{ii}{jj};
P = Ps{ii}{jj};

% converting transformed coordinates to original coordinates:
Ricp_invT = inv(Ricp');
Po = (Pt - Ticp' + c2) * Ricp_invT + c1;

% converting inferior + superior coordinates to original coordinates:
infPointso = (infPoints - Ticp' + c2) * Ricp_invT + c1;
supPointso = (supPoints - Ticp' + c2) * Ricp_invT + c1;

% converting inferior + superior normal vectos to original coordinates:
normInfo = (normInf) * Ricp_invT;
normSupo = (normSup) * Ricp_invT;

% normalizing and setting normal vectors to be defined as outwards:
normInfo = normInfo / norm(normInfo) * sign(-normInfo(:,3));
normSupo = normSupo / norm(normSupo) * sign(normSupo(:,3));

% determining vertebral wedging:
cos_theta = dot(normSupo, -normInfo) / (norm(normSupo) * norm(normInfo));
wedge_rad = acos(cos_theta); % angle in radians
wedge_deg = rad2deg(wedge_rad); % angle in degrees
disp("Vertebral body wedging (degrees): " + string(wedge_deg))

%% Getting inferior + superior normal vector features

% centroids of inferior + superior coordinates:
avgH = mean(heights);
infPointCen = mean(infPointso, 1);
supPointCen = mean(supPointso, 1);

% determining point of plotting:
fl = 0.00;
scale = fl * avgH;
infPointPlot = infPointCen + normInfo * scale;
supPointPlot = supPointCen + normSupo * scale;

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
    subplot(3,3,9);
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
    subplot(3,3,[1 5]);
    cla
    hold on
    scatter3(Po(:,1), Po(:,2), Po(:,3))
    scatter3(P(:,1), P(:,2), P(:,3))
    scatter3(infPointso(:,1), infPointso(:,2), infPointso(:,3))
    scatter3(supPointso(:,1), supPointso(:,2), supPointso(:,3))
    qInf = quiver3(infPointPlot(:,1), infPointPlot(:,2), infPointPlot(:,3), ...
                normInfo(:,1), normInfo(:,2), normInfo(:,3), 3, 'k', 'LineWidth', 3);
    qInf.MaxHeadSize = 3;
    qSup = quiver3(supPointPlot(:,1), supPointPlot(:,2), supPointPlot(:,3), ...
                normSupo(:,1), normSupo(:,2), normSupo(:,3), 3, 'k', 'LineWidth', 3);
    qSup.MaxHeadSize = 3;
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
    title('Original untransformed goemetry (sagittal view), ' + string(round(wedge_deg, 2)) + char(176) + ' wedging')
    legend('MATLAB', '.stl', 'inf', 'sup', 'norm, inf', 'norm, sup', 'Location', 'best');
    view(90, 0) % YZ plane
    drawnow
end

makegif = false;
if makegif
    giffilename = 'height_measurement.gif';
    figure
    hold on
    scatter3(infPoints(:,1), infPoints(:,2), infPoints(:,3))
    scatter3(supPoints(:,1), supPoints(:,2), supPoints(:,3))
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
    title('Inferior and superior surfaces')
    view(45, 35.264) % isometric view
    numPoints = length(refPoints);
    numHeights = ceil(numPoints/50); % # of vectors to be displayed per frame
    numIter = floor(numPoints/numHeights); % # of iterations
    for v = 1:numIter
        vecs = ((v-1) * numHeights + 1):(v*numHeights);
        quiver3(refPoints(vecs,1), refPoints(vecs,2), refPoints(vecs,3), ...
                        r(vecs,1), r(vecs,2), r(vecs,3), 'r', ...
                        'linewidth', 1, 'AutoScale','off')
        legend('inferior surface', 'superior surface', 'height measurement')
        frame = getframe(gcf);
        img = frame2im(frame);
        [imind, cm] = rgb2ind(img, 256);
    
        % Write to GIF
        if v == 1
            imwrite(imind, cm, giffilename, 'gif', 'Loopcount', inf, 'DelayTime', 0.001);
        else
            imwrite(imind, cm, giffilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.001);
        end
    end
end

%% MATLAB cleanup

% deleting everything except areas and Z:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'hfig', 'hAP', 'yAP', 'hlat', 'xlat', 'apratio', 'lrratio', 'areaInf', 'areaSup', 'normInfo', 'normSupo', 'wedge_deg', 'infPointPlot', 'supPointPlot'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
