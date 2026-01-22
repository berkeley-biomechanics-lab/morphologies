%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: summarizeData.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 1-21-2026
%
% Description: transporting subject data from 'data/measurements' files,
% summarizing it all into easy-to-use data structures, visualizing the
% summarized raw data, and exporting for SPM Python analysis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

%% MEASUREMENT TABLES
% Constructs measurement table 'T' based on the subject data in the 
% 'data/measurements' repository

% Command window update:
fprintf('Summarizing measurements ...\n');

% Includes both vertebral & disc data:
[Tslice, Theight, Tvolume, Theightrs] = buildMeasurementTables(cfg);

%% RAW VISUALIZATION
% Visualizing the raw data; accounting for each experiemental group, {X,Y,Z}
% direction, and measurement types {csa, widths, etc}

% Endpoint spinal levels to be visualized:
levels = cfg.summary.levelsVisualized;

% ---- Slicer measurements (using the following settings) ----
%       Structure : vertebra & disc
%       Grouping  : kyphotic (blue) VS control (red)
%       Plot Type : line
%       Axes      : X, Y, and Z (vertebra) and Z (disc)
plotRawSlicer(Tslice,'CSA','Structure','vertebra','Group','separate', 'AxesList', 'XYZ','Levels',levels)
plotRawSlicer(Tslice,'CSA','Structure','disc','Group','separate','AxesList', 'Z','Levels',levels)

% ---- Height measurements (using the following settings) ----
%       Structure : vertebra & disc
%       Grouping  : kyphotic (blue) VS control (red)
%       PlotType  : line
%       Axes      : LAT and AP
plotRawHeight(Theight,'Height','Structure','vertebra','Group','separate','Levels',levels)
plotRawHeight(Theight,'Height','Structure','disc','Group','separate','Levels',levels)

% ---- Volume measurements (using the following settings) ----
%       Structure: vertebra & disc
%       Grouping : kyphotic (blue) VS control (red)
%       PlotType : line
plotRawVolume(Tvolume,'Structure','vertebra','Levels',levels)
plotRawVolume(Tvolume,'Structure','disc','Levels',levels)

% ---- Height ratio measurements (using the following settings) ----
%       Structure: vertebra & disc
%       Grouping : kyphotic (blue) VS control (red)
%       PlotType : line
plotRawHeightRs(Theightrs,'Structure','vertebra','Levels',levels)
plotRawHeightRs(Theightrs,'Structure','disc','Levels',levels)

%% BODY LEVEL MORPHOLOGY ANALYSIS
% Performing level-specific two-sample t-tests on body level morphology
% metrics (i.e. volume)

% Endpoint spinal levels to be exported:
levelRange = cfg.summary.levelsExported;

% ---- VOLUME ----
% Computing level-wise t-tests from volume summary table:
[TvolVertStats, volVertStats] = levelwiseTtests(Tvolume, 'vertebra', levelRange, 'Volume');
[TvolDiscStats, volDiscStats] = levelwiseTtests(Tvolume, 'disc', levelRange, 'Volume');

% Visualizing level-wise t-tests from volume summary table:
plotLevelwiseStats( ...
    TvolVertStats, 'vertebra', ...
    'YLabel','Volume (mm^3)', ...
    'Title','Vertebral Body Volume (Level-wise)', ...
    'UseQ', true);
plotLevelwiseStats( ...
    TvolDiscStats, 'disc', ...
    'YLabel','Volume (mm^3)', ...
    'Title','Disc Body Volume (Level-wise)', ...
    'UseQ', true);

% Reporting increases in volume/level data (mm^3/level):
fprintf('Control vertebral body volume increases by an average of %f mm^3/level!\n', mean(diff(TvolVertStats.MeanC)))
fprintf('Kyphotic vertebral body volume increases by an average of %f mm^3/level!\n', mean(diff(TvolVertStats.MeanK)))

fprintf('Control disc body volume increases by an average of %f mm^3/level!\n', mean(diff(TvolDiscStats.MeanC)))
fprintf('Kyphotic disc body volume increases by an average of %f mm^3/level!\n', mean(diff(TvolDiscStats.MeanK)))

% Reporting relative difference between control and kyphotic (%):
maxRelDiffVert = max((TvolVertStats.MeanC - TvolVertStats.MeanK)./TvolVertStats.MeanK * 100);
minRelDiffVert = min((TvolVertStats.MeanC - TvolVertStats.MeanK)./TvolVertStats.MeanK * 100);

maxRelDiffDisc = max((TvolDiscStats.MeanC - TvolDiscStats.MeanK)./TvolDiscStats.MeanK * 100);
minRelDiffDisc = min((TvolDiscStats.MeanC - TvolDiscStats.MeanK)./TvolDiscStats.MeanK * 100);

fprintf(['Vertebral body volumes from control specimens were %f - %f %% ' ...
    'greater than kyphotic vertebral bodies at every level!\n'], minRelDiffVert, maxRelDiffVert)
fprintf(['Disc body volumes from control specimens were %f - %f %% ' ...
    'greater than kyphotic vertebral bodies at every level!\n'], minRelDiffDisc, maxRelDiffDisc)

% ---- HEIGHT RATIO ----
axes = {'LAT','AP'};

% Computing level-wise t-tests from height ratio summary table, vertebra; both axes:
[ThrsLATVertStats, hrsLATVertStats] = levelwiseTtests(Theightrs(Theightrs.Axis == axes{1},:), 'vertebra', levelRange, 'HeightR');
[ThrsAPVertStats, hrsAPVertStats]   = levelwiseTtests(Theightrs(Theightrs.Axis == axes{2},:), 'vertebra', levelRange, 'HeightR');

% disc; both axes:
[ThrsLATDiscStats, hrsLATDiscStats] = levelwiseTtests(Theightrs(Theightrs.Axis == axes{1},:), 'disc', levelRange, 'HeightR');
[ThrsAPDiscStats, hrsAPDiscStats]   = levelwiseTtests(Theightrs(Theightrs.Axis == axes{2},:), 'disc', levelRange, 'HeightR');

% Visualizing level-wise t-tests from height ratio summary tables:
plotLevelwiseStats( ...
    ThrsLATVertStats, 'vertebra', ...
    'YLabel','Height Ratio (mm/mm)', ...
    'Title','Vertebral LAT Height Ratio (Level-wise)', ...
    'UseQ', true);
plotLevelwiseStats( ...
    ThrsAPVertStats, 'vertebra', ...
    'YLabel','Height Ratio (mm/mm)', ...
    'Title','Vertebral AP Height Ratio (Level-wise)', ...
    'UseQ', true);

plotLevelwiseStats( ...
    ThrsLATDiscStats, 'disc', ...
    'YLabel','Height Ratio (mm/mm)', ...
    'Title','Disc LAT Height Ratio (Level-wise)', ...
    'UseQ', true);
plotLevelwiseStats( ...
    ThrsAPDiscStats, 'disc', ...
    'YLabel','Height Ratio (mm/mm)', ...
    'Title','Disc AP Height Ratio (Level-wise)', ...
    'UseQ', true);

%% SPM EXTRACT
% Extracting SPM-ready matrices from the measumrent tables

% The slicer and height measurements are spatially sampled measurements.
% SPM requires a 2D matrix as its input, so these measurements will be set
% up with the dimensions: (NxQ) where
%       N = total number of levels across subjects
%       Q = native mesaurement sampling frequency (numSlices or heightResolution)
%
% Each native measurement will have a kyphotic and control SPM data array
% associated with it.

% ---- Slicer summary arrays (vertebra and disc, Z-axis, CSA) ----
[YcVertZ, YkVertZ, metaVertZ] = buildLevelStackedArray( ...
    Tslice, 'csa', 'Z', 'vertebra', levelRange);

[YcDiscZ, YkDiscZ, metaDiscZ] = buildLevelStackedArray( ...
    Tslice, 'csa', 'Z', 'disc', levelRange);

% ---- Height summary arrays (vertebra and disc, LAT and AP, Height) ----
[YcVertLAT, YkVertLAT, metaVertLAT] = buildLevelStackedArray( ...
    Theight, 'height', 'LAT', 'vertebra', levelRange);
[YcDiscLAT, YkDiscLAT, metaDiscLAT] = buildLevelStackedArray( ...
    Theight, 'height', 'LAT', 'disc', levelRange);

[YcVertAP, YkVertAP, metaVertAP] = buildLevelStackedArray( ...
    Theight, 'height', 'AP', 'vertebra', levelRange);
[YcDiscAP, YkDiscAP, metaDiscAP] = buildLevelStackedArray( ...
    Theight, 'height', 'AP', 'disc', levelRange);

%% EXPORTING
% Exporting 2D summary arrays to 'data\summary' for Python SPM analysis

sumPath = cfg.paths.sumMeasurements; % summary file path

% ---- SLICER: Exporting summary arrays (vertebra and disc) ----
vertZ = struct(); vertZ.notes = 'Vertebra Z-plane CSA profile';
vertZ.levels = metaVertZ.levelRange; vertZ.axis = metaVertZ.axis;
vertZ.measurement = metaVertZ.measurement; vertZ.structure = metaVertZ.structure;
exportSPMArray(sumPath, 'vertZ', YcVertZ, YkVertZ, vertZ);

discZ = struct(); discZ.notes = 'Disc Z-plane CSA profile';
discZ.levels = metaDiscZ.levelRange; discZ.axis = metaDiscZ.axis;
discZ.measurement = metaDiscZ.measurement; discZ.structure = metaDiscZ.structure;
exportSPMArray(sumPath, 'discZ', YcDiscZ, YkDiscZ, discZ);

% ---- HEIGHT: Exporting summary arrays (vertebra and disc, LAT and AP) ----
vertLAT = struct(); vertLAT.notes = 'Vertebra LAT-plane height profile';
vertLAT.levels = metaVertLAT.levelRange; vertLAT.axis = metaVertLAT.axis;
vertLAT.measurement = metaVertLAT.measurement; vertLAT.structure = metaVertLAT.structure;
exportSPMArray(sumPath, 'vertLAT', YcVertLAT, YkVertLAT, vertLAT);

discLAT = struct(); discLAT.notes = 'Disc LAT-plane CSA profile';
discLAT.levels = metaDiscLAT.levelRange; discLAT.axis = metaDiscLAT.axis;
discLAT.measurement = metaDiscLAT.measurement; discLAT.structure = metaDiscLAT.structure;
exportSPMArray(sumPath, 'discLAT', YcDiscLAT, YkDiscLAT, discLAT);

vertAP = struct(); vertAP.notes = 'Vertebra AP-plane height profile';
vertAP.levels = metaVertAP.levelRange; vertAP.axis = metaVertAP.axis;
vertAP.measurement = metaVertAP.measurement; vertAP.structure = metaVertAP.structure;
exportSPMArray(sumPath, 'vertAP', YcVertAP, YkVertAP, vertAP);

discAP = struct(); discAP.notes = 'Disc AP-plane CSA profile';
discAP.levels = metaDiscAP.levelRange; discAP.axis = metaDiscAP.axis;
discAP.measurement = metaDiscAP.measurement; discAP.structure = metaDiscAP.structure;
exportSPMArray(sumPath, 'discAP', YcDiscAP, YkDiscAP, discAP);

%% MATLAB CLEANUP
% Clearing leftover workspace variables, except the measurement tables:
clearvars -except Tslice Theight Tvolume Theightrs cfg;

