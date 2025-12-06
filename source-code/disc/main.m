%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Implementing a joint vertebra + disc --> spine visualizing procedure
% using the vertebral geometries that have been pre-processed in 3D Slicer.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

set(0,'DefaultFigureWindowStyle','docked')
warning('off','all')

%% Measurement properties
% Unless otherwise stated, dimensions are in mm

% processing properties:
compressPer = 0; % percentage of mask bonudary compression (ranges from 0-100)
ns = 500; % # of CSA slices
nh = 1000; % # of height measurements

%% Importing segmentation measurement data

% path of the segmentation measurement data:
folderPath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\vertebrae\measurements";

% loading all measurement data:
direcPath = dir(fullfile(folderPath, '*.mat'));
for i = 1:length(direcPath)
    baseFileName = direcPath(i).name;
    fullFileName = fullfile(folderPath, baseFileName);

    load(fullFileName) % loading .mat file
end

%% Segmentation repository processing

% number of discs adjustment:
numDiscLevels = numLevels - 1;
numDiscLevelsAct = zeros(size(numDiscLevels)); % actual number of discs in each subject

% disc processing loop:
for ii = 1:length(subjects)
    subj = subjects{ii}; % subject name
    for jj = 1:numDiscLevels(ii)
        % disc segmentation information
        Iinf = jj + 1; % index of inferior vertebra
        Isup = jj; % index of superior vertebra
        infLvl = levels{ii}{Iinf}; % inferior vertebral level name
        supLvl = levels{ii}{Isup}; % superior vertebral level name

        % disc level processing
        vertebraPair = [supLvl, '-', infLvl];
        indPair = extract([infLvl, supLvl], digitsPattern); % levels of vertebra pair
        diffLevel = abs(str2double(indPair{2}) - str2double(indPair{1})); % interval space in between vertebra pair

        % given the disc space is valid, we can now process the disc geometry
        if diffLevel == 1 || strcmp(vertebraPair, 'T15-L1')
            numDiscLevelsAct(ii) = numDiscLevelsAct(ii) + 1; % adjusting disc level counter
        end
    end
end

% paths of all disc segmentation geometries:
discLevelNames = cell(length(subjects), 1); % level names of all disc levels in each subject spine
discPaths = cell(length(subjects), 1); % path names of all disc levels in each subject spine
alphas = cell(length(subjects), 1); % alphas of all disc levels in each subject spine
for ii = 1:length(subjects)
    discLevelNames{ii} = cell(numDiscLevelsAct(ii), 1);
    discPaths{ii} = cell(numDiscLevelsAct(ii), 1);
    alphas{ii} = cell(numDiscLevelsAct(ii), 1);
end

% updating names and paths of all disc segmentation geometries:
for ii = 1:length(subjects)
    subj = subjects{ii}; % subject name
    for jj = 1:numDiscLevels(ii)
        % disc segmentation information
        Iinf = jj + 1; % index of inferior vertebra
        Isup = jj; % index of superior vertebra
        infLvl = levels{ii}{Iinf}; % inferior vertebral level name
        supLvl = levels{ii}{Isup}; % superior vertebral level name

        % disc level processing
        vertebraPair = [supLvl, '-', infLvl];
        indPair = extract([infLvl, supLvl], digitsPattern); % levels of vertebra pair
        diffLevel = abs(str2double(indPair{2}) - str2double(indPair{1})); % interval space in between vertebra pair

        % given the disc space is valid, we can now process the disc geometry
        if diffLevel == 1 || strcmp(vertebraPair, 'T15-L1')
            % file information for disc surface mesh data .stl file:
            fileName = [vertebraPair, '.stl'];
            folderPath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\discs\disc-stls";
            subjectFolderPath = fullfile(folderPath, subj);
            discSubjectFolderPath = char(fullfile(subjectFolderPath, fileName));

            % updating variables:
            empty_indices_paths = find(cellfun(@isempty, discPaths{ii})); % finding the indices of all empty cells
            first_empty_index_paths = empty_indices_paths(1);
            discPaths{ii}{first_empty_index_paths} = discSubjectFolderPath;

            % naming disc level:
            empty_indices = find(cellfun(@isempty, discLevelNames{ii})); % finding the indices of all empty cells
            first_empty_index = empty_indices(1);
            discLevelNames{ii}{first_empty_index} = vertebraPair;
        end
    end
end

%% Storage array processing

% area measurements storage:
areasDisc = cell(length(subjects), 1); % areas with respect to slice position Z
ZsDisc = cell(length(subjects), 1); % slice positions, defined to start at 0

% 3D measurements storage:
volDiscs = cell(length(subjects), 1); % volume of each disc
discWedges = cell(length(subjects), 1); % disc wedge degrees of each disc
normDiscInfs = cell(length(subjects), 1); % net normal vector of inferior surface of each disc
normDiscSups = cell(length(subjects), 1); % net normal vector of superior surface of each disc
pointDiscPlotInfs = cell(length(subjects), 1); % position of normal vector of inferior surface of each disc
pointDiscPlotSups = cell(length(subjects), 1); % position of normal vector of superior surface of each disc

% intermediate variables storage (used for landmark selection process):
Ps_disc  = cell(length(subjects), 1); % original coordinates of all subjects
Pts_disc  = cell(length(subjects), 1); % transformed coordinates of all subjects
R_disc  = cell(length(subjects), 1); % ICP rotation matrix of all subjects

supPts_disc  = cell(length(subjects), 1); % superior coordinates of all subjects (pre-transformation)
infPts_disc  = cell(length(subjects), 1); % inferior coordinates of all subjects (pre-transformation)

% height measurements storage:
hAPs = cell(length(subjects), 1); % AP heights with respect to AP position
yAPs = cell(length(subjects), 1); % AP positions, defined to start at 0

% mapping each subject's levels to the storage matrices:
for ii = 1:length(subjects)
    % constructing area measurement storage matrices:
    areasDisc{ii} = cell(numDiscLevelsAct(ii), 1); % area of subject ii
    ZsDisc{ii} = cell(numDiscLevelsAct(ii), 1); % slice positions of subject ii

    % constructing 3D measurement storage matrices:
    volDiscs{ii} = cell(numDiscLevelsAct(ii), 1); % volume of subject ii
    discWedges{ii} = cell(numDiscLevelsAct(ii), 1); % disc wedge degrees area of subject ii
    normDiscInfs{ii} = cell(numDiscLevelsAct(ii), 1); % net normal vector of inferior surface of subject ii
    normDiscSups{ii} = cell(numDiscLevelsAct(ii), 1); % net normal vector of superior surface of subject ii
    pointDiscPlotInfs{ii} = cell(numDiscLevelsAct(ii), 1); % position of normal vector of inferior surface of subject ii
    pointDiscPlotSups{ii} = cell(numDiscLevelsAct(ii), 1); % position of normal vector of superior surface of subject ii

    % constructing intermediate variables storage matrices:
    Ps_disc{ii} = cell(numDiscLevelsAct(ii), 1); % original coordinates of subject ii
    Pts_disc{ii} = cell(numDiscLevelsAct(ii), 1); % transformed coordinates of subject ii
    R_disc{ii} = cell(numDiscLevelsAct(ii), 1); % ICP rotation matrix of subject ii
    
    supPts_disc{ii} = cell(numDiscLevelsAct(ii), 1); % superior coordinates of subject ii (pre-transformation)
    infPts_disc{ii} = cell(numDiscLevelsAct(ii), 1); % inferior coordinates of subject ii (pre-transformation)

    % height measurements storage:
    hAPs{ii} = cell(numDiscLevelsAct(ii), 1); % AP heights with respect to AP position of subject ii
    yAPs{ii} = cell(numDiscLevelsAct(ii), 1); % AP positions of subject ii
end

%% Disc geometry exporting
% Disc surface processing is slightly different from vertebra surface
% processing. Disc surface modeling requires the inferior surface of one
% vertebra and the superior surface of another vertebra.

% disc export loop:
makeexport = true;
if makeexport
    for ii = 1:length(subjects)
        subj = subjects{ii}; % subject name
        for jj = 1:numDiscLevels(ii)
            % disc segmentation information
            Iinf = jj + 1; % index of inferior vertebra
            Isup = jj; % index of superior vertebra
            infLvl = levels{ii}{Iinf}; % inferior vertebral level name
            supLvl = levels{ii}{Isup}; % superior vertebral level name
            infLvlPath = levelPaths{ii}{Iinf}; % inferior vertebral level path name
            supLvlPath = levelPaths{ii}{Isup}; % superior vertebral level path name
    
            % disc level processing
            vertebraPair = [supLvl, '-', infLvl];
            indPair = extract([infLvl, supLvl], digitsPattern); % levels of vertebra pair
            diffLevel = abs(str2double(indPair{2}) - str2double(indPair{1})); % interval space in between vertebra pair
    
            % transformation properties:
            RicpInf = Ricps{ii}{Iinf};
            RicpSup = Ricps{ii}{Isup};
            TicpInf = Ticps{ii}{Iinf};
            TicpSup = Ticps{ii}{Isup};
            c1Inf = c1s{ii}{Iinf};
            c1Sup = c1s{ii}{Isup};
            c2Inf = c2s{ii}{Iinf};
            c2Sup = c2s{ii}{Isup};
    
            % given the disc space is valid, we can now process the disc geometry
            if diffLevel == 1  || strcmp(vertebraPair, 'T15-L1')
                % inferior and superior transformed coordinates:
                infPt = Pts{ii}{Iinf}; 
                supPt = Pts{ii}{Isup};
    
                % inferior and superior original coordinates:
                infPo = Ps{ii}{Iinf}; 
                supPo = Ps{ii}{Isup};
    
                % inferior and superior disc landmark selection variables
                PVInfVertSupPlane = supPVs{ii}{Iinf}; % vertices that describe superior surface boundary plane of vertebra Iinf
                PVSupVertInfPlane = infPVs{ii}{Isup}; % vertices that describe inferior surface boundary plane of vertebra Isup
                
                % measure disc surfaces
                exportDiscGeometry; % writes disc geometries to .stl file
            end
    
            clc; % clearing command window
        end
    end
end

% disc inferior + superior surface measurement loop:
findpointclouds = true;
if findpointclouds
    for ii = 1:length(subjects)
        subj = subjects{ii}; % subject name
        for jj = 1:numDiscLevels(ii)
            % disc segmentation information
            Iinf = jj + 1; % index of inferior vertebra
            Isup = jj; % index of superior vertebra
            infLvl = levels{ii}{Iinf}; % inferior vertebral level name
            supLvl = levels{ii}{Isup}; % superior vertebral level name
            infLvlPath = levelPaths{ii}{Iinf}; % inferior vertebral level path name
            supLvlPath = levelPaths{ii}{Isup}; % superior vertebral level path name
    
            % disc level processing
            vertebraPair = [supLvl, '-', infLvl];
            indPair = extract([infLvl, supLvl], digitsPattern); % levels of vertebra pair
            diffLevel = abs(str2double(indPair{2}) - str2double(indPair{1})); % interval space in between vertebra pair
    
            % transformation properties:
            RicpInf = Ricps{ii}{Iinf};
            RicpSup = Ricps{ii}{Isup};
            TicpInf = Ticps{ii}{Iinf};
            TicpSup = Ticps{ii}{Isup};
            c1Inf = c1s{ii}{Iinf};
            c1Sup = c1s{ii}{Isup};
            c2Inf = c2s{ii}{Iinf};
            c2Sup = c2s{ii}{Isup};
    
            % given the disc space is valid, we can now process the disc geometry
            if diffLevel == 1  || strcmp(vertebraPair, 'T15-L1')
                % inferior and superior transformed coordinates:
                infPt = Pts{ii}{Iinf}; 
                supPt = Pts{ii}{Isup};
    
                % inferior and superior original coordinates:
                infPo = Ps{ii}{Iinf}; 
                supPo = Ps{ii}{Isup};
    
                % inferior and superior disc landmark selection variables
                PVInfVertSupPlane = supPVs{ii}{Iinf}; % vertices that describe superior surface boundary plane of vertebra Iinf
                PVSupVertInfPlane = infPVs{ii}{Isup}; % vertices that describe inferior surface boundary plane of vertebra Isup
                
                % measure disc surfaces
                exportDiscPlanes; % finds inferior + superior surface point clouds

                % superior coordinates of disc:
                empty_indices_sup = find(cellfun(@isempty, supPts_disc{ii})); % finding the indices of all empty cells
                first_empty_index_sup = empty_indices_sup(1);
                supPts_disc{ii}{first_empty_index_sup} = supDiscPointso;

                % inferior coordinates of disc:
                empty_indices_inf = find(cellfun(@isempty, infPts_disc{ii})); % finding the indices of all empty cells
                first_empty_index_inf = empty_indices_inf(1);
                infPts_disc{ii}{first_empty_index_inf} = infDiscPointso;
            end
    
            clc; % clearing command window
        end
    end
end

%% Disc wedging measurements

% disc wedging measurement loop:
for ii = 1:length(subjects)
    subj = subjects{ii}; % subject name
    for jj = 1:numDiscLevels(ii)
        % disc segmentation information
        Iinf = jj + 1; % index of inferior vertebra
        Isup = jj; % index of superior vertebra
        infLvl = levels{ii}{Iinf}; % inferior vertebral level name
        supLvl = levels{ii}{Isup}; % superior vertebral level name
        infLvlPath = levelPaths{ii}{Iinf}; % inferior vertebral level path name
        supLvlPath = levelPaths{ii}{Isup}; % superior vertebral level path name

        % disc level processing
        vertebraPair = [supLvl, '-', infLvl];
        indPair = extract([infLvl, supLvl], digitsPattern); % levels of vertebra pair
        diffLevel = abs(str2double(indPair{2}) - str2double(indPair{1})); % interval space in between vertebra pair

        % given the disc space is valid, we can now process the disc geometry
        if diffLevel == 1  || strcmp(vertebraPair, 'T15-L1')
            % inferior normal vector:
            empty_indices_normInf = find(cellfun(@isempty, normDiscInfs{ii})); % finding the indices of all empty cells
            first_empty_index_normInf = empty_indices_normInf(1);
            normalDiscInf = -normSups{ii}{Iinf};
            normDiscInfs{ii}{first_empty_index_normInf} = normalDiscInf;
            
            % superior normal vector:
            empty_indices_normSup = find(cellfun(@isempty, normDiscSups{ii})); % finding the indices of all empty cells
            first_empty_index_normSup = empty_indices_normSup(1);
            normalDiscSup = -normInfs{ii}{Isup};
            normDiscSups{ii}{first_empty_index_normSup} = normalDiscSup;

            % position of inferior normal vector:
            empty_indices_inf = find(cellfun(@isempty, pointDiscPlotInfs{ii})); % finding the indices of all empty cells
            first_empty_index_inf = empty_indices_inf(1);
            pointDiscPlotInfs{ii}{first_empty_index_inf} = pointPlotSups{ii}{Iinf};

            % position of superior normal vector:
            empty_indices_sup = find(cellfun(@isempty, pointDiscPlotSups{ii})); % finding the indices of all empty cells
            first_empty_index_sup = empty_indices_sup(1);
            pointDiscPlotSups{ii}{first_empty_index_sup} = pointPlotInfs{ii}{Isup};

            % determining disc wedging:
            cos_theta = dot(normalDiscSup, -normalDiscInf) / (norm(normalDiscSup) * norm(normalDiscInf));
            wedge_rad = acos(cos_theta); % angle in radians
            wedge_deg = rad2deg(wedge_rad); % angle in degrees

            empty_indices_wedge = find(cellfun(@isempty, discWedges{ii})); % finding the indices of all empty cells
            first_empty_index_wedge = empty_indices_wedge(1);
            discWedges{ii}{first_empty_index_wedge} = wedge_deg;
        end

        clc; % clearing command window
    end
end

%% Disc cross sectional area measurement processing

% disc cross sectional area measurement loop:
for ii = 1:length(subjects)
    for jj = 1:numDiscLevelsAct(ii)
        % disc information
        subj = subjects{ii}; % subject name
        lvl = discLevelNames{ii}{jj}; % level name
        discFilePath = discPaths{ii}{jj};

        % measure disc volume and surface area
        loadDisc; % returns Pc, c1, and P; centered geometry, translation vector, and original geometry

        % getting normal vectors:
        infNorm = normDiscInfs{ii}{jj};
        supNorm = normDiscSups{ii}{jj};

        % align geometry
        alignDisc; % returns Pt and R; transformed geometry (via ICP)

        % measure cross sectional area
        measureDiscArea; % returns areaZ, Z; area and slice position measurements

        % updating intermediate values:
        Ps_disc{ii}{jj} = P;
        Pts_disc{ii}{jj} = Pt;
        R_disc{ii}{jj} = R;

        % updating measurements; ii = subject, jj = level
        areasDisc{ii}{jj} = areaZ;
        ZsDisc{ii}{jj} = Z;

        clc; % clearing command window
    end
end

%% Disc height measurement processing

% main disc height measurement loop:
for ii = 1:length(subjects)
    for jj = 1:numDiscLevelsAct(ii)
        % disc information
        subj = subjects{ii}; % subject name
        lvl = discLevelNames{ii}{jj}; % level name

        % landmark selection variables (area --> height)
        R = R_disc{ii}{jj};
        P_disc = Ps_disc{ii}{jj} - mean(Ps_disc{ii}{jj});
        Pt_disc = Pts_disc{ii}{jj} - mean(Pts_disc{ii}{jj});
        supPoints = supPts_disc{ii}{jj};
        infPoints = infPts_disc{ii}{jj};

        % measure height
        measureDiscHeight; % returns hAP, yAP; height measurements

        % updating measurements; ii = subject, jj = level
        hAPs{ii}{jj} = hAP;
        yAPs{ii}{jj} = yAP;

        clc; % clearing command window
    end
end

%% Proxy disc area + height bulk measurements for experiment

% experiment disc levels of interest:
discLoI = {'T12-T13', ...
            'T13-T14', ...
            'T14-T15', ...
            'T15-L1', ...
            'L1-L2', ...
            'L2-L3'};

% trimmed mean of middle f% of values in measurement vector:
fArea = 0.75;
fHeight = 0.75;

% mean area + height measurements storage:
meanAreasDisc = cell(length(subjects), 1);
meanHeightsDisc = cell(length(subjects), 1);

% proxy disc area + height reporting loop:
for ii = 1:length(subjects)
    meanAreasDisc{ii} = zeros(length(discLoI), 1);
    meanHeightsDisc{ii} = zeros(length(discLoI), 1);

    for jj = 1:numDiscLevelsAct(ii)
        discLevelName = discLevelNames{ii}{jj}; % disc level name

        if contains(discLevelName, discLoI)
            rawArea = areasDisc{ii}{jj};
            rawAPHeight = hAPs{ii}{jj};
            meanArea = middleFracMean(rawArea, fArea);
            meanAPHeight = middleFracMean(rawAPHeight, fHeight);

            % level of interest index:
            idxLoI = find(strcmp(discLoI, discLevelName));
            meanAreasDisc{ii}(idxLoI) = meanArea;
            meanHeightsDisc{ii}(idxLoI) = meanAPHeight;
        end
    end
end

%% Disc volume and total surface area measurements

% disc volume and total surface area measurement loop:
for ii = 1:length(subjects)
    subj = subjects{ii}; % subject name
    for jj = 1:numDiscLevelsAct(ii)
        % updating measurements; ii = subject, jj = level
        volDiscs{ii}{jj} = trapz(ZsDisc{ii}{jj}, areasDisc{ii}{jj});

        clc; % clearing command window
    end
end

%% Visualizing disc levels

% number of figures:
nfigs = length(subjects);

% plotting all subjects' discs levels:
makeplot = false;
if makeplot
    for ii = 1:nfigs
        subjName = subjects{ii}; % subject name of subject ii
        numDiscLevel = numDiscLevelsAct(ii); % number of levels of subject ii
    
        % initializing figure features:
        figure
        hold on
        axis equal
        view(3)
        xlabel('X'); ylabel('Y'); zlabel('Z')
        title("Disc levels of subject " + subjName)
    
        % reading and plotting .stl geometries:
        for jj = 1:numDiscLevel
            filePath = discPaths{ii}{jj}; % path of disc level segmentation .stl file

            % getting normal vectors:
            infNorm = normDiscInfs{ii}{jj};
            supNorm = normDiscSups{ii}{jj};

            % getting position of normal vectors:
            infPointPlot = pointDiscPlotInfs{ii}{jj};
            supPointPlot = pointDiscPlotSups{ii}{jj};

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
                        infNorm(:,1), infNorm(:,2), infNorm(:,3), 6, 'r', 'LineWidth', 3);
            qInf.MaxHeadSize = 3;
            qSup = quiver3(supPointPlot(:,1), supPointPlot(:,2), supPointPlot(:,3), ...
                        supNorm(:,1), supNorm(:,2), supNorm(:,3), 6, 'r', 'LineWidth', 3);
            qSup.MaxHeadSize = 3;
        end
        
        camlight;
        lighting gouraud;
        view(90, 0) % YZ plane
        drawnow;
    end
end

%% Visualizing vertebrae + disc levels

% number of figures:
nfigs = length(subjects);

% plotting all subjects' discs levels:
makeplot = true;
if makeplot
    for ii = 1:nfigs
        % plotting discs for subject ii
        subjName = subjects{ii}; % subject name of subject ii
        numDiscLevel = numDiscLevelsAct(ii); % number of levels of subject ii
    
        % initializing figure features:
        figure
        hold on
        axis equal
        view(3)
        xlabel('X'); ylabel('Y'); zlabel('Z')
        title("Spine of subject " + subjName)
    
        % reading and plotting .stl geometries:
        for jj = 1:numDiscLevel
            filePath = discPaths{ii}{jj}; % path of disc level segmentation .stl file

            % getting normal vectors:
            infNorm = normDiscInfs{ii}{jj};
            supNorm = normDiscSups{ii}{jj};

            % getting position of normal vectors:
            infPointPlot = pointDiscPlotInfs{ii}{jj};
            supPointPlot = pointDiscPlotSups{ii}{jj};

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
        end
        
        % plotting vertebrae for subject ii
        numVertLevel = numLevels(ii); % number of levels of subject ii
    
        % reading and plotting .stl geometries:
        for jj = 1:numVertLevel
            filePath = levelPaths{ii}{jj}; % path of vertebral level segmentation .stl file
    
            % reading .stl geometry:
            [TR, ~, ~, ~] = stlread(filePath);  % returns faces (f), vertices (v)
    
            v = TR.Points; % Nx3 matrix of vertices
            f = TR.ConnectivityList; % Mx3 matrix of triangle vertex indices
    
            % plotting .stl geometry:
            patch('Faces', TR.ConnectivityList, ...
                  'Vertices', TR.Points, ...
                  'FaceColor', rand(1,3), ...
                  'EdgeColor', 'none');          
        end
                       
        camlight;
        lighting gouraud;
        view(90, 0) % YZ plane
        drawnow;
    end
end

%% Exporting measurements

% measurement folder file path:
measurePath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\discs\measurements";

% subject properties:
save(append(measurePath, '\', 'subjects.mat'), 'subjects');

% disc geometry properties:
save(append(measurePath, '\', 'discLevelNames.mat'), 'discLevelNames');

% 3D variables:
save(append(measurePath, '\', 'volDiscs.mat'), 'volDiscs');
save(append(measurePath, '\', 'discWedges.mat'), 'discWedges');

% area variables:
save(append(measurePath, '\', 'areasDisc.mat'), 'areasDisc');
save(append(measurePath, '\', 'ZsDisc.mat'), 'ZsDisc');

% height variables:
save(append(measurePath, '\', 'heightAP.mat'), 'hAPs');
save(append(measurePath, '\', 'yAPs.mat'), 'yAPs');
