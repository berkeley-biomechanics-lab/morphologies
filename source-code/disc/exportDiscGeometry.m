%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the coordinates of the inferior and superior surfaces of the disc
% a vertebra, this program constructs and exports disc geometries
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc

% script variables:
varsbefore = who;

%% Determining equation of inferior/superior bonudary planes for the disc
% choosing three vertices and calculate two vectors, where there are two
% coordinate systems: 1.) the superior surface of the disc (the inferior
% surface of the top vertebra) and 2.) the inferior surface of the disc
% (the superior surface of the bottom vertebra). infv1 + infv2 represent
% the superior coordinate vectors on the inferior vertebral geometry that 
% will determine (2) and supv1 + supv2 represent the inferior coordinate 
% vectors on the superior vertebral geometry that will determine (1).
% PVInfVertSupPlane represents the vertices that describe superior surface 
% boundary plane of vertebra Iinf and supPV represents the vertices that 
% describe inferior surface boundary plane of vertebra Isup:
v1InfVertSupPlane = PVInfVertSupPlane(2,:) - PVInfVertSupPlane(1,:);
v2InfVertSupPlane = PVInfVertSupPlane(3,:) - PVInfVertSupPlane(1,:);
v1SupVertInfPlane = PVSupVertInfPlane(2,:) - PVSupVertInfPlane(1,:);
v2SupVertInfPlane = PVSupVertInfPlane(3,:) - PVSupVertInfPlane(1,:);

% calculating normal vector, for each vertebral plane:
v3InfVertSupPlane = cross(v1InfVertSupPlane, v2InfVertSupPlane);
v3SupVertInfPlane = cross(v1SupVertInfPlane, v2SupVertInfPlane);

% choosing vertex and finding equation, for each vertebral plane:
DInfVertSupPlane = -v3InfVertSupPlane * PVInfVertSupPlane(1,:)';
DSupVertInfPlane = -v3SupVertInfPlane * PVSupVertInfPlane(1,:)';
pInfVertSupPlane = [v3InfVertSupPlane, DInfVertSupPlane]';
pSupVertInfPlane = [v3SupVertInfPlane, DSupVertInfPlane]';

%% Determining inferior/superior vertebral surfaces

% calculating z-coordinates on inferior/superior planes:
zOnInfVertSupPlane = (-pInfVertSupPlane(1)*infPt(:,1) ...
                        - pInfVertSupPlane(2)*infPt(:,2) ...
                        - pInfVertSupPlane(4)) ./ pInfVertSupPlane(3);
zOnSupVertInfPlane = (-pSupVertInfPlane(1)*supPt(:,1) ...
                        - pSupVertInfPlane(2)*supPt(:,2) ...
                        - pSupVertInfPlane(4)) ./ pSupVertInfPlane(3);

% comparing z-coordinates to boundary planes:
aboveInfVertSupPlane = infPt(:,3) >= zOnInfVertSupPlane;
belowSupVertInfPlane = supPt(:,3) <= zOnSupVertInfPlane;

% partitioning inferior/superior surfaces:
supDiscPoints = supPt(belowSupVertInfPlane,:);
infDiscPoints = infPt(aboveInfVertSupPlane,:);

% converting inferior + superior coordinates to original coordinates:
RicpSup_invT = inv(RicpSup');
RicpInf_invT = inv(RicpInf');
supDiscPointso = (supDiscPoints - TicpSup' + c2Sup) * RicpSup_invT + c1Sup;
infDiscPointso = (infDiscPoints - TicpInf' + c2Inf) * RicpInf_invT + c1Inf;

% visualizing original geometries:
makeplot = false;
makenewfig = false;
if makeplot
    if makenewfig
        figure;
    elseif ~exist('ofig','var') || ~ishandle(ofig)
        ofig = figure;
    else
        set(0, 'CurrentFigure', ofig)
        clf('reset')
    end
    figtitle = vertebraPair + ", " + subj + ' original untransformed goemetry (sagittal view)';

    hold on;
    plot3(infPo(:,1), infPo(:,2), infPo(:,3), '.');
    plot3(supPo(:,1), supPo(:,2), supPo(:,3), '.');
    plot3(infDiscPointso(:,1), infDiscPointso(:,2), infDiscPointso(:,3), '.');
    plot3(supDiscPointso(:,1), supDiscPointso(:,2), supDiscPointso(:,3), '.');
    hold off
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title(figtitle)
    legend('inf, vert', 'sup, vert', 'inf, disc','sup, disc');
    view(90, 0) % YZ plane
    axis equal; grid on;
    drawnow;
end

%% Finding surface areas of inferior/superior disc surfaces

% repartitioning inferior + superior vertices:
verticesInf = infDiscPointso;
xxInf = verticesInf(:,1); 
yyInf = verticesInf(:,2);
zzInf = verticesInf(:,3);

verticesSup = supDiscPointso;
xxSup = verticesSup(:,1); 
yySup = verticesSup(:,2);
zzSup = verticesSup(:,3);

% getting 2D boundary of inferior + superior point clouds:
sf = 1; % shrink factor, 0 --> convex hull and 1 --> compact boundary
[IbSup, ~] = boundary(xxSup, yySup, sf);
x2DSup_b = xxSup(IbSup);
y2DSup_b = yySup(IbSup);
z2DSup_b = ones(size(x2DSup_b)) * max(zzSup);

[IbInf, ~] = boundary(xxInf, yyInf, sf);
x2DInf_b = xxInf(IbInf);
y2DInf_b = yyInf(IbInf);
z2DInf_b = ones(size(x2DInf_b)) * min(zzInf);

% Pick a projection plane for parameterization (example: XY)
gridRes = 300; % resolution
[xqSup, yqSup] = meshgrid(linspace(min(xxSup), max(xxSup), gridRes), ...
                               linspace(min(yySup), max(yySup), gridRes));
[xqInf, yqInf] = meshgrid(linspace(min(xxInf), max(xxInf), gridRes), ...
                           linspace(min(yyInf), max(yyInf), gridRes));

% setting boundary of inferior + superior regions:
pgonSup = polyshape(x2DSup_b, y2DSup_b); % x2D_b, y2D_b: polygon vertices
inPgonSupVec = isinterior(pgonSup, xqSup(:), yqSup(:)); % x, y: query points
inPgonSupArr = reshape(inPgonSupVec, gridRes, gridRes);

pgonInf = polyshape(x2DInf_b, y2DInf_b); % x2D_b, y2D_b: polygon vertices
inPgonInfVec = isinterior(pgonInf, xqInf(:), yqInf(:)); % x, y: query points
inPgonInfArr = reshape(inPgonInfVec, gridRes, gridRes);

% compressing boundary points:
m = floor(compressPer/100 * gridRes/2); % divide by factor of 2 to account for uniform compression 
se = strel('disk', m); % creating a disk-shaped structuring element of radius m 
inPgonSupArr = imerode(inPgonSupArr, se); % shrinking mask by requiring distance > m
inPgonInfArr = imerode(inPgonInfArr, se); % shrinking mask by requiring distance > m

% Interpolate Z values from scattered (x,y,z) 
outPgonSupArr = ~inPgonSupArr; 
outPgonInfArr = ~inPgonInfArr; 
zqSup = griddata(xxSup, yySup, zzSup, xqSup, yqSup, 'natural'); 
zqSup(outPgonSupArr) = NaN; zqSup(outPgonInfArr) = NaN;

zqInf = griddata(xxInf, yyInf, zzInf, xqInf, yqInf, 'natural'); 
zqInf(outPgonInfArr) = NaN; 
zqInf(outPgonSupArr) = NaN;

% mask of boundary points in original grids: 
validMaskSup = ~isnan(zqSup); % creating a validity mask for superior surface 
validMaskInf = ~isnan(zqInf); % creating a validity mask for inferior surface

% indices of mask of boundary points in original grids: 
BWSup = validMaskSup; 
BSup = bwboundaries(BWSup); % cell array of boundaries 
boundaryRCSup = BSup{1}; % first boundary [row, col] points, ordered 
linIdxSup = sub2ind(size(BWSup), boundaryRCSup(:,1), boundaryRCSup(:,2)); % converting to linear indices

BWInf = validMaskInf; 
BInf = bwboundaries(BWInf); % cell array of boundaries 
boundaryRCInf = BInf{1}; % first boundary [row, col] points, ordered 
linIdxInf = sub2ind(size(BWInf), boundaryRCInf(:,1), boundaryRCInf(:,2)); % converting to linear indices

% determining outer boundary coordinates: 
outerBoundary3DSup = [xqSup(linIdxSup), yqSup(linIdxSup), zqSup(linIdxSup)]; 
outerBoundary3DInf = [xqInf(linIdxInf), yqInf(linIdxInf), zqInf(linIdxInf)]; 

% smoothing boundary curves: 
xqSup(linIdxSup) = outerBoundary3DSup(:,1); 
yqSup(linIdxSup) = outerBoundary3DSup(:,2); 
zqSup(linIdxSup) = outerBoundary3DSup(:,3); 

xqInf(linIdxInf) = outerBoundary3DInf(:,1); 
yqInf(linIdxInf) = outerBoundary3DInf(:,2); 
zqInf(linIdxInf) = outerBoundary3DInf(:,3);

% interpolating between the inferior/superior disc surfaces: 
N = 20; % number of interior surfaces

% intializing total coordinate arrays: 
xxx = zeros((N+2)*gridRes, gridRes); 
xxx(1:gridRes, 1:gridRes) = xqInf; 
xxx((N+1)*gridRes + 1:(N+2)*gridRes, 1:gridRes) = xqSup; 

yyy = zeros((N+2)*gridRes, gridRes); 
yyy(1:gridRes, 1:gridRes) = yqInf; 
yyy((N+1)*gridRes + 1:(N+2)*gridRes, 1:gridRes) = yqSup; 

zzz = zeros((N+2)*gridRes, gridRes); 
zzz(1:gridRes, 1:gridRes) = zqInf; 
zzz((N+1)*gridRes + 1:(N+2)*gridRes, 1:gridRes) = zqSup;

% storing interior surfaces: 
for iii = 1:N 
    tt = iii / (N+1); 
    xxMid = (1 - tt) * xqInf + tt * xqSup; 
    xxx(iii*gridRes + 1:(iii+1)*gridRes, 1:gridRes) = xxMid; 

    yyMid = (1 - tt) * yqInf + tt * yqSup; 
    yyy(iii*gridRes + 1:(iii+1)*gridRes, 1:gridRes) = yyMid; 

    zzMid = (1 - tt) * zqInf + tt * zqSup; 
    zzz(iii*gridRes + 1:(iii+1)*gridRes, 1:gridRes) = zzMid; 
end

% plotting: 
makeplot = false; 
makenewfig = false; 
if makeplot 
    if makenewfig 
        figure; 
    elseif ~exist('interpfig','var') || ~ishandle(interpfig) 
        interpfig = figure; 
    else 
        set(0, 'CurrentFigure', interpfig) 
        figure(interpfig) 
        clf('reset') 
    end 
    figtitle = vertebraPair + ", " + subj + ' disc interpolated surface layers'; 
    hold on; 

    surf(xqSup, yqSup, zqSup, 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]); 
    surf(xqInf, yqInf, zqInf, 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]); 
    scatter3(xqSup(linIdxSup), yqSup(linIdxSup), zqSup(linIdxSup), 'r.');
    scatter3(xqInf(linIdxInf), yqInf(linIdxInf), zqInf(linIdxInf), 'r.');
    plot3(outerBoundary3DSup(:,1), outerBoundary3DSup(:,2), outerBoundary3DSup(:,3), 'k-');
    plot3(outerBoundary3DInf(:,1), outerBoundary3DInf(:,2), outerBoundary3DInf(:,3), 'k-');
    
    % plotting interior surfaces: 
    for iii = 1:N 
        tt = iii / (N+1); 
        xxMid = (1 - tt) * xqInf + tt * xqSup; 
        yyMid = (1 - tt) * yqInf + tt * yqSup; 
        zzMid = (1 - tt) * zqInf + tt * zqSup; 
        
        surfMid = surf(xxMid, yyMid, zzMid); 
        surfMid.FaceAlpha = 0.5; 
        surfMid.EdgeColor = 'none'; 
        surfMid.FaceColor = 'r'; 
    end 
    view(3) 
    title(figtitle) 
    xlabel("X"); ylabel("Y"); zlabel("Z"); 
    axis equal; grid on; drawnow;
end

%% Enclosing surfaces 

% flattening cooridinates into vectors: 
xv = xxx(:); 
yv = yyy(:); 
zv = zzz(:); 

% finding the logical locations of NaNs: 
nanLocations = isnan(zv); 

% repartitioning coordinate vectors: 
xvv = xv(~nanLocations); 
yvv = yv(~nanLocations); 
zvv = zv(~nanLocations); 
Vvv = [xvv, yvv, zvv]; 

% k is a tightness parameter (1 = tightest wrap, smaller <1 = tighter wrap)
k = 1;
F = boundary(xvv, yvv, zvv, k); % F = faces, indices into point list

%% Exporting disc geometry

% file information for disc surface mesh data .stl file:
fileName = [vertebraPair, '.stl'];
subjectFolderPath = fullfile(folderPath, subj);
discSubjectFolderPath = char(fullfile(subjectFolderPath, fileName));

% exporting directly to STL:
V = [xvv, yvv, zvv];
TR = triangulation(F, V);
stlwrite(TR, discSubjectFolderPath);

% boolean operations if shrink factor <= threshold
discPath = discSubjectFolderPath;
supPath = supLvlPath;
infPath = infLvlPath;

% Replace backslashes with forward slashes
supPath = strrep(supPath, '\', '/');
discPath = strrep(discPath, '\', '/');
infPath = strrep(infPath, '\', '/');

% create a simple SCAD model 
% this could also just be written externally and reused
% writing scripts via fprintf() is ridiculously cumbersome
% though it demonstrates that names, etc. can be programmatically incorporated
fid = fopen('temp.scad','w');
fprintf(fid,'difference(){\n\timport("%s");\n\timport("%s");\n\timport("%s");\n}', ...
                discPath, supPath, infPath);
fclose(fid);

% compute the composite geometry, output as a new STL
% Choose your output file dynamically
outFile = discSubjectFolderPath;   % character array
scadFile = 'temp.scad';

% Build the command string
cmd = sprintf('openscad -o "%s" "%s"', outFile, scadFile);

% Run system command
[status, result] = system(cmd);
TRnew = stlread(discSubjectFolderPath);

meshTest = surfaceMesh(TRnew.Points, TRnew.ConnectivityList);
isWTtest = isWatertight(meshTest);

% read the new STL as a triangulation object and display it:
makeplot = true;
makenewfig = false; 
if makeplot 
    if makenewfig 
        figure; 
    elseif ~exist('boolfig','var') || ~ishandle(boolfig)
        boolfig = figure; 
    else 
        set(0, 'CurrentFigure', boolfig) 
        figure(boolfig) 
        clf('reset') 
    end 
    figtitle = vertebraPair + ", " + subj + ' disc geometry, ' + string(compressPer) + '% compression (post-boolean operation)'; 
    
    hs = trisurf(TRnew, 'FaceColor','interp', 'Edgecolor', 'none');

    % Get the vertex coordinates
    V = TRnew.Points;

    % Use Z coordinate as the color data
    hs.CData = V(:,3);   % Z values

    axis equal; view(3); title(figtitle); 
    xlabel("X"); ylabel("Y"); zlabel("Z"); 
    axis equal; grid on; drawnow;
end

%% Checking overlap with vertebrae

% checking for overlap with vertebrae:
makecheck = false;
makeplotVol = false;
if makecheck
    disc = TR; % disc triangulation object

    % loading vertebral .stl meshes:
    supVert = stlread(supLvlPath);
    infVert = stlread(infLvlPath);
    
    % combining all vertices to get global bounding box for superior + inferior
    % check:
    allSupVerts = [supVert.Points; disc.Points];
    minXSup = min(allSupVerts(:,1)); maxXSup = max(allSupVerts(:,1));
    minYSup = min(allSupVerts(:,2)); maxYSup = max(allSupVerts(:,2));
    minZSup = min(allSupVerts(:,3)); maxZSup = max(allSupVerts(:,3));
    
    allInfVerts = [infVert.Points; disc.Points];
    minXInf = min(allInfVerts(:,1)); maxXInf = max(allInfVerts(:,1));
    minYInf = min(allInfVerts(:,2)); maxYInf = max(allInfVerts(:,2));
    minZInf = min(allInfVerts(:,3)); maxZInf = max(allInfVerts(:,3));
    
    % defining a voxel grid (resolution controls accuracy):
    gridSize = 15; % increase for higher accuracy
    [supxq, supyq, supzq] = ndgrid(linspace(minXSup, maxXSup, gridSize), ...
                                    linspace(minYSup, maxYSup, gridSize), ...
                                    linspace(minZSup, maxZSup, gridSize));
    [infxq, infyq, infzq] = ndgrid(linspace(minXInf, maxXInf, gridSize), ...
                                    linspace(minYInf, maxYInf, gridSize), ...
                                    linspace(minZInf, maxZInf, gridSize));
    
    % inside/outside test:
    discSup = in_polyhedron(disc.ConnectivityList, disc.Points, [supxq(:), supyq(:), supzq(:)]);
    discInf = in_polyhedron(disc.ConnectivityList, disc.Points, [infxq(:), infyq(:), infzq(:)]);
    inSup = in_polyhedron(supVert.ConnectivityList, supVert.Points, [supxq(:), supyq(:), supzq(:)]);
    inInf = in_polyhedron(infVert.ConnectivityList, infVert.Points, [infxq(:), infyq(:), infzq(:)]);
    
    % reshaping to 3D binary masks:
    maskDiscSup = reshape(discSup, size(supxq));
    maskDiscInf = reshape(discInf, size(infxq));
    maskVertSup = reshape(inSup, size(supxq));
    maskVertInf = reshape(inInf, size(infxq));
    
    % computing overlapping volume:
    voxelVolSup = (range(supxq(:))/gridSize) * ...
                    (range(supyq(:))/gridSize) * ...
                    (range(supzq(:))/gridSize);
    overlapVolSup = sum(maskDiscSup & maskVertSup, 'all') * voxelVolSup;
    
    voxelVolInf = (range(infxq(:))/gridSize) * ...
                    (range(infyq(:))/gridSize) * ...
                    (range(infzq(:))/gridSize);
    overlapVolInf = sum(maskDiscInf & maskVertInf, 'all') * voxelVolInf;
    
    [vol, ~] = stlVolume(disc.Points', disc.ConnectivityList'); % volume vol and surface area surfarea of .stl file
    
    % relative (%) volume overlap:
    relOverlapVolSup = round(overlapVolSup/vol * 100, 3);
    relOverlapVolInf = round(overlapVolInf/vol * 100, 3);
    if makeplotVol
        set(0, 'CurrentFigure', surffig)
        figure(surffig)

        if makeplot
            figtitle = vertebraPair + ", " + subj + ' disc surface mesh, ' + ...
                    string(compressPer) + '% compression, k = ' + string(k) + ...
                    " --> " + string(relOverlapVolSup) + '% superior + ' + ...
                    string(relOverlapVolInf) + '% inferior overlap';
        else
            figtitle = vertebraPair + ", " + subj + ' disc surface mesh --> ' + ...
                    string(relOverlapVolSup) + '% superior + ' + string(relOverlapVolInf) + '% inferior overlap';
        end
        
        title(figtitle);
    end

    % storing maximum overlap measurement:
    if ~exist('maxOverlap','var')
        maxOverlap = max([relOverlapVolSup, relOverlapVolInf]);
    else
        maxOverlap = max([maxOverlap, max([relOverlapVolSup, relOverlapVolInf])]);
    end
end

%% MATLAB cleanup

% deleting everything except areas and Z:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'ofig', 'interpfig', 'surffig', 'maxOverlap', 'mink', 'boolfig', 'counter', 'sumk', 'avgk'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
