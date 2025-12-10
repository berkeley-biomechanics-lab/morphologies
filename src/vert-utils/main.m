%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Implementing a joint volume + area + height measurement program to measure
% vertebral geometries that have been pre-processed in 3D Slicer.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

set(0,'DefaultFigureWindowStyle','docked')
warning('off','all')

%% Measurement properties
% Unless otherwise stated, dimensions are in mm

% processing properties:
ns = 150; % # of CSA slices
nk = 200; % # of icp iterations
nh = 1000; % # of height measurements

% additional paths:
addpath('refs');

% reference geometries:
references = {'ref_658_T4_final', 'ref_658_T11_final', 'ref_658_L3_final'};

%% Segmentation repository processing

% path to segmentation repo:
folderPath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\vertebra-stls";

% extracting repository details:
folderPathProps = dir(fullfile(folderPath,'*')); % folderPath properties
subjects = setdiff({folderPathProps([folderPathProps.isdir]).name},{'.','..'}); % list of subfolders of folderPath
numLevels = zeros(length(subjects), 1); % number of levels in each subject spine
levels = cell(length(numLevels), 1); % string names of all levels in each subject spine (naturally sorted)
levelPaths = cell(length(numLevels), 1); % path names of all levels in each subject spine (naturally sorted)
for ii = 1:numel(subjects)
    subj = subjects{ii}; % subject name
    subjectRepoProps = dir(fullfile(folderPath, subj, '*')); % specifying the file extension
    levelNames = {subjectRepoProps(~[subjectRepoProps.isdir]).name}; % files in subfolder
    numLevels(ii) = length(levelNames);
    levels{ii} = cell(numLevels(ii), 1);
    levelPaths{ii} = cell(numLevels(ii), 1);
    for jj = 1:numLevels(ii)
        stlName = levelNames{jj}; % name of .stl file

        % splitting the string by underscores:
        parts = strsplit(stlName, '_');
        lvl = parts{3};
        lvl = lvl(1:end-4); % name of level
        filePath = fullfile(folderPath, subj, stlName); % path name of level

        % assigning level and .stl file path information to storage arrays:
        levels{ii}{jj} = lvl;
        levelPaths{ii}{jj} = char(filePath);
    end
end

% naturally sorting levels information:
for ii = 1:numel(subjects)
    levels{ii} = natsortfiles(levels{ii});
    levelPaths{ii} = natsortfiles(levelPaths{ii});

    % reordering with respect to anatomical location:
    containsT = cellfun(@(x) contains(x, 'T'), levels{ii});
    containsL = cellfun(@(x) contains(x, 'L'), levels{ii});
    levels{ii} = [levels{ii}(containsT); levels{ii}(containsL)];
    levelPaths{ii} = [levelPaths{ii}(containsT); levelPaths{ii}(containsL)];
end

%% Storage array processing

% area measurements storage:
areas = cell(length(subjects), 1); % areas with respect to slice position Z
Zs = cell(length(subjects), 1); % slice positions, defined to start at 0

% width measurements storage:
wAPs = cell(length(subjects), 1); % AP width with respect to slice position Z
wlats = cell(length(subjects), 1); % lateral width with respect to slice position Z
zAPs = cell(length(subjects), 1); % AP width with respect to slice position Z
zlats = cell(length(subjects), 1); % lateral width with respect to slice position Z
widxs = cell(length(subjects), 1); % indexes of superior and inferior slices for means
polyshapes = cell(length(subjects), 1); % polyshapes of all slices

% intermediate variables storage (used for landmark selection process):
Ps  = cell(length(subjects), 1); % original coordinates of all subjects
Pts  = cell(length(subjects), 1); % transformed coordinates of all subjects
Ricps  = cell(length(subjects), 1); % ICP rotation matrix of all subjects
Ticps  = cell(length(subjects), 1); % ICP translation vector of all subjects
c1s  = cell(length(subjects), 1); % 1st center translation vector of all subjects
c2s  = cell(length(subjects), 1); % 2nd center translation vector of all subjects
infPVs = cell(length(subjects), 1); % vertices that describe inferior surface boundary plane
supPVs = cell(length(subjects), 1); % vertices that describe superior surface boundary plane

% height measurements storage:
hAPs = cell(length(subjects), 1); % AP heights with respect to AP position
yAPs = cell(length(subjects), 1); % AP positions, defined to start at 0
hlats = cell(length(subjects), 1); % Lateral heights with respect to lateral position
xlats = cell(length(subjects), 1); % Lateral positions, defined to start at 0
apratios = cell(length(subjects), 1); % AP height ratios of each vertebrae
lrratios = cell(length(subjects), 1); % Lateral height ratios of each vertebrae
areaInfs = cell(length(subjects), 1); % Inferior surface areas of each vertebrae
areaSups = cell(length(subjects), 1); % Superior surface areas of each vertebrae

% 3D measurements storage:
vols = cell(length(subjects), 1); % volumes of each vertebrae
surfareas = cell(length(subjects), 1); % surface areas of each vertebrae
normInfs = cell(length(subjects), 1); % net normal vectors of inferior surface of each vertebrae (original coordinates)
normSups = cell(length(subjects), 1); % net normal vectors of superior surface of each vertebrae (original coordinates)
pointPlotInfs = cell(length(subjects), 1); % representative point of inferior surface of each vertebrae (original coordinates)
pointPlotSups = cell(length(subjects), 1); % representative point of superior surface of each vertebrae (original coordinates)
vertebralWedges = cell(length(subjects), 1); % vertebral body wedge degrees of each vertebrae

% mapping each subject's levels to the storage matrices:
for ii = 1:length(subjects)
    % constructing area measurement storage matrices:
    areas{ii} = cell(numLevels(ii), 1); % area of subject ii
    Zs{ii} = cell(numLevels(ii), 1); % slice positions of subject ii

    % constructing intermediate storage matrices:
    Ps{ii} = cell(numLevels(ii), 1); % original coordinates of subject ii
    Pts{ii} = cell(numLevels(ii), 1); % transformed coordinates of subject ii
    Ricps{ii} = cell(numLevels(ii), 1); % ICP rotation matrix of subject ii
    Ticps{ii} = cell(numLevels(ii), 1); % ICP translation vector of subject ii
    c1s{ii} = cell(numLevels(ii), 1); % 1st center translation vector of subject ii
    c2s{ii} = cell(numLevels(ii), 1); % 2nd center translation vector of subject ii
    infPVs{ii} = cell(numLevels(ii), 1); % vertices that describe inferior surface boundary plane of subject ii
    supPVs{ii} = cell(numLevels(ii), 1); % vertices that describe superior surface boundary plane of subject ii

    % constructing width measurements storage matrices:
    wAPs{ii} = cell(numLevels(ii), 1); % AP width with respect to slice position Z
    wlats{ii} = cell(numLevels(ii), 1); % Lateral width with respect to slice position Z
    zAPs{ii} = cell(numLevels(ii), 1); % Z position of AP width dimension
    zlats{ii} = cell(numLevels(ii), 1); % Z position of lateral width dimension

    % constructing height measurement storage matrices:
    hAPs{ii} = cell(numLevels(ii), 1); % AP heights with respect to AP position of subject ii
    yAPs{ii} = cell(numLevels(ii), 1); % AP positions of subject ii
    hlats{ii} = cell(numLevels(ii), 1); % Lateral heights with respect to lateral position subject ii
    xlats{ii} = cell(numLevels(ii), 1); % Lateral positions of subject ii
    apratios{ii} = cell(numLevels(ii), 1); % AP height ratios of subject ii
    lrratios{ii} = cell(numLevels(ii), 1); % Lateral height ratios area of subject ii

    % constructing 3D measurement storage matrices:
    vols{ii} = cell(numLevels(ii), 1); % volumes of subject ii
    surfareas{ii} = cell(numLevels(ii), 1); % surface areas of subject ii
    normInfs{ii} = cell(numLevels(ii), 1); % net normal vector of inferior surfaces of subject ii
    normSups{ii} = cell(numLevels(ii), 1); % net normal vector of superior surfaces of subject ii
    pointPlotInfs{ii} = cell(numLevels(ii), 1); % representative point of inferior surfaces of subject ii
    pointPlotSups{ii} = cell(numLevels(ii), 1); % representative point of superior surfaces of subject ii
    vertebralWedges{ii} = cell(numLevels(ii), 1); % vertebral body wedge degrees of subject ii
end

%% Surface area + volume measurement processing

% main segmentation 3D measurement loop:
for ii = 1:length(subjects)
    for jj = 1:numLevels(ii)
        % segmentation information
        filePath = levelPaths{ii}{jj}; % .stl file name

        % measure volume and surface area
        measureVertebrae3D; % returns vol, surfarea

        % updating measurements; ii = subject, jj = level
        vols{ii}{jj} = vol;
        surfareas{ii}{jj} = surfarea;

        clc; % clearing command window
    end
end

%% Cross sectional area measurement processing

% main segmentation area measurement loop:
for ii = 1:length(subjects)
    for jj = 1:numLevels(ii)
        % segmentation information
        subj = subjects{ii}; % subject name
        lvl = levels{ii}{jj}; % level name
        filePath = levelPaths{ii}{jj}; % .stl file name

        % load (and centers) geometry
        loadVertebrae; % returns Pc, c1, and P; centered geometry, translation vector, and original geometry
        
        % align geometry
        alignVertebrae; % returns Pt, Ricp, Ticp, and c2; transformed geometry (via ICP)

        % measure cross sectional area
        measureVertebraeArea; % returns areaZ, Z, infPV, supPV; area and slice position measurements
       
        % updating measurements; ii = subject, jj = level
        areas{ii}{jj} = areaZ;
        Zs{ii}{jj} = Z;

        % updating width indexes and polyshapes
        widxs{ii}{jj} = [inf_ind, sup_ind];
        polyshapes{ii}{jj} = ps;

        % updating intermediate values:
        Ps{ii}{jj} = P;
        Pts{ii}{jj} = Pt;
        Ricps{ii}{jj} = Ricp;
        Ticps{ii}{jj} = Ticp;
        c1s{ii}{jj} = c1;
        c2s{ii}{jj} = c2;
        infPVs{ii}{jj} = infPV;
        supPVs{ii}{jj} = supPV;

        clc; % clearing command window
    end
end

%% Width measurement processing

% main segmentation width measurement loop:
for ii = 1:length(subjects)
    for jj = 1:numLevels(ii)
        % segmentation information
        subj = subjects{ii}; % subject name
        lvl = levels{ii}{jj}; % level name
        filePath = levelPaths{ii}{jj}; % .stl file name

        % slice information
        sls = polyshapes{ii}{jj};
        indices = widxs{ii}{jj};

        % measure AP and lateral widths
        measureVertebraeWidth; % returns wAPslices and wlatslices and zAPslices and zlatslices

        % updating width measurements:
        wAPs{ii}{jj} = wAPslices; % AP widths of all slices in one subject
        wlats{ii}{jj} = wlatslices; % lateral widths of all slices in one subject
        zAPs{ii}{jj} = zAPslices; % Z position of AP width dimension in one subject
        zlats{ii}{jj} = zlatslices; % Z position of lateral width dimensions in one subject

        clc; % clearing command window
    end
end

%% Height measurement processing

% main segmentation height measurement loop:
for ii = 1:length(subjects)
    for jj = 1:numLevels(ii)
        % segmentation information
        subj = subjects{ii}; % subject name
        lvl = levels{ii}{jj}; % level name

        % landmark selection variables (area --> height)
        Pt = Pts{ii}{jj};
        infPV = infPVs{ii}{jj};
        supPV = supPVs{ii}{jj};

        % measure height
        measureVertebraeHeight; % returns hAP, yAP, hlat, xlat, apratio, lrratio, areaInf, areaSup, normInf, normSup, wedge_deg, infPointPlot, supPointPlot; height measurements

        % updating measurements; ii = subject, jj = level
        hAPs{ii}{jj} = hAP;
        yAPs{ii}{jj} = yAP;
        hlats{ii}{jj} = hlat;
        xlats{ii}{jj} = xlat;
        apratios{ii}{jj} = apratio;
        lrratios{ii}{jj} = lrratio;
        areaInfs{ii}{jj} = areaInf;
        areaSups{ii}{jj} = areaSup;
        normInfs{ii}{jj} = normInfo;
        normSups{ii}{jj} = normSupo;
        vertebralWedges{ii}{jj} = wedge_deg;
        pointPlotInfs{ii}{jj} = infPointPlot;
        pointPlotSups{ii}{jj} = supPointPlot;

        clc; % clearing command window
    end
end

%% Visualizing vertebral levels

% number of figures:
nfigs = length(subjects);

% plotting all subjects' vertebral levels:
makeplot = true;
if makeplot
    for ii = 1:nfigs
        subjName = subjects{ii}; % subject name of subject ii
        numVertLevel = numLevels(ii); % number of levels of subject ii
    
        % initializing figure features:
        figure
        hold on
        axis equal
        view(3)
        xlabel('X'); ylabel('Y'); zlabel('Z')
        title("Vertebral levels of subject " + subjName + " (sagittal view)")
    
        % reading and plotting .stl geometries:
        for jj = 1:numVertLevel
            filePath = levelPaths{ii}{jj}; % path of vertebral level segmentation .stl file

            % getting normal vectors:
            infNorm = normInfs{ii}{jj};
            supNorm = normSups{ii}{jj};

            % getting position of normal vectors:
            infPointPlot = pointPlotInfs{ii}{jj};
            supPointPlot = pointPlotSups{ii}{jj};

            % creating a grid of (x, y) points
            sideLength = 20;
            [xGridInf, yGridInf] = meshgrid(linspace(infPointPlot(:,1)-sideLength, infPointPlot(:,1)+sideLength, sideLength), ...
                                            linspace(infPointPlot(:,2)-sideLength, infPointPlot(:,2)+sideLength, sideLength));
            [xGridSup, yGridSup] = meshgrid(linspace(supPointPlot(:,1)-sideLength, supPointPlot(:,1)+sideLength, sideLength), ...
                                            linspace(supPointPlot(:,2)-sideLength, supPointPlot(:,2)+sideLength, sideLength));
    
            % plane equation: solving for z
            aInf = infNorm(1); bInf = infNorm(2); cInf = infNorm(3);
            zGridInf = ( -aInf*(xGridInf - infPointPlot(1)) - bInf*(yGridInf - infPointPlot(2)) ) / cInf + infPointPlot(3);
            aSup = supNorm(1); bSup = supNorm(2); cSup = supNorm(3);
            zGridSup = ( -aSup*(xGridSup - supPointPlot(1)) - bSup*(yGridSup - supPointPlot(2)) ) / cSup + supPointPlot(3);

            % reading .stl geometry:
            [TR, ~, ~, ~] = stlread(filePath);  % returns faces (f), vertices (v)
    
            v = TR.Points; % Nx3 matrix of vertices
            f = TR.ConnectivityList; % Mx3 matrix of triangle vertex indices
    
            % plotting .stl geometry:
            patch('Faces', TR.ConnectivityList, ...
                  'Vertices', TR.Points, ...
                  'FaceColor', rand(1,3), ...
                  'EdgeColor', 'none');
            surf(xGridInf, yGridInf, zGridInf, 'FaceColor', [1 1 0], 'EdgeColor', 'none')
            surf(xGridSup, yGridSup, zGridSup, 'FaceColor', [1 1 0], 'EdgeColor', 'none')
            qInf = quiver3(infPointPlot(:,1), infPointPlot(:,2), infPointPlot(:,3), ...
                        infNorm(:,1), infNorm(:,2), infNorm(:,3), 3, 'r', 'LineWidth', 0.75);
            qInf.MaxHeadSize = 1.5;
            qSup = quiver3(supPointPlot(:,1), supPointPlot(:,2), supPointPlot(:,3), ...
                        supNorm(:,1), supNorm(:,2), supNorm(:,3), 3, 'r', 'LineWidth', 0.75);
            qSup.MaxHeadSize = 1.5;
        end
        
        camlight;
        lighting gouraud;
        view(90, 0) % YZ plane
        drawnow;
    end
end

%% Exporting measurements

% measurement folder file path:
measurePath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\vertebrae\measurements";

% height variables:
save(append(measurePath, '\', 'heightAP.mat'), 'hAPs');
save(append(measurePath, '\', 'apPositions.mat'), 'yAPs');
save(append(measurePath, '\', 'heightLat.mat'), 'hlats');
save(append(measurePath, '\', 'latPositions.mat'), 'xlats');
save(append(measurePath, '\', 'apratios.mat'), 'apratios');
save(append(measurePath, '\', 'lrratios.mat'), 'lrratios');
save(append(measurePath, '\', 'areaInfs.mat'), 'areaInfs');
save(append(measurePath, '\', 'areaSups.mat'), 'areaSups');

% area variables:
save(append(measurePath, '\', 'areas.mat'), 'areas');
save(append(measurePath, '\', 'slicePositions.mat'), 'Zs');

% width variables:
save(append(measurePath, '\', 'wAPs.mat'), 'wAPs');
save(append(measurePath, '\', 'wlats.mat'), 'wlats');
save(append(measurePath, '\', 'zAPs.mat'), 'zAPs');
save(append(measurePath, '\', 'zlats.mat'), 'zlats');

% 3D variables:
save(append(measurePath, '\', 'vols.mat'), 'vols');
save(append(measurePath, '\', 'surfareas.mat'), 'surfareas');
save(append(measurePath, '\', 'normInfs.mat'), 'normInfs');
save(append(measurePath, '\', 'normSups.mat'), 'normSups');
save(append(measurePath, '\', 'pointPlotInfs.mat'), 'pointPlotInfs');
save(append(measurePath, '\', 'pointPlotSups.mat'), 'pointPlotSups');
save(append(measurePath, '\', 'vertebralWedges.mat'), 'vertebralWedges');

% intermediate segmentation variables:
save(append(measurePath, '\', 'Ps.mat'), 'Ps');
save(append(measurePath, '\', 'Pts.mat'), 'Pts');
save(append(measurePath, '\', 'Ricps.mat'), 'Ricps');
save(append(measurePath, '\', 'Ticps.mat'), 'Ticps');
save(append(measurePath, '\', 'c1s.mat'), 'c1s');
save(append(measurePath, '\', 'c2s.mat'), 'c2s');
save(append(measurePath, '\', 'infPVs.mat'), 'infPVs');
save(append(measurePath, '\', 'supPVs.mat'), 'supPVs');

% segmentation variables:
save(append(measurePath, '\', 'subjects.mat'), 'subjects');
save(append(measurePath, '\', 'levels.mat'), 'levels');
save(append(measurePath, '\', 'numLevels.mat'), 'numLevels');
save(append(measurePath, '\', 'levelPaths.mat'), 'levelPaths');
