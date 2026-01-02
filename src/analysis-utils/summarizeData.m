%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: summarizeData.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 1-1-2026
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
[Tslice, Theight, Tvolume] = buildMeasurementTables(cfg);

%% RAW VISUALIZATION
% Visualizing the raw data; accounting for each experiemental group, {X,Y,Z}
% direction, and measurement types {csa, widths, etc}

% Endpoint spinal levels to be visualized:
levels = ["T1","L6"]; % choosing levels associated with major apex region

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

% Endpoint spinal levels to be exported:
levels = ["T14","L3"]; % choosing levels associated with major apex region

% ---- Slicer summary arrays (vertebra and disc, Z-axis, CSA) ----
[YcVertZ, YkVertZ, metaVertZ] = buildLevelStackedArray( ...
    Tslice, 'csa', 'Z', 'vertebra', levels);

[YcDiscZ, YkDiscZ, metaDiscZ] = buildLevelStackedArray( ...
    Tslice, 'csa', 'Z', 'disc', levels);

% ---- Height summary arrays (vertebra and disc, LAT and AP, Height) ----
[YcVertLAT, YkVertLAT, metaVertLAT] = buildLevelStackedArray( ...
    Theight, 'height', 'LAT', 'vertebra', levels);
[YcDiscLAT, YkDiscLAT, metaDiscLAT] = buildLevelStackedArray( ...
    Theight, 'height', 'LAT', 'disc', levels);

[YcVertAP, YkVertAP, metaVertAP] = buildLevelStackedArray( ...
    Theight, 'height', 'AP', 'vertebra', levels);
[YcDiscAP, YkDiscAP, metaDiscAP] = buildLevelStackedArray( ...
    Theight, 'height', 'AP', 'disc', levels);

% Scalar measurements like volume are position-based sampled measurements.
% SPM requires a 2D matrix as its input, so these measurements will be set
% up with the dimensions: (NxQ) where
%       N = total number subjects
%       Q = number of resolved levels (ordered spinal levels)
[YcVertVol, YkVertVol, levelsVertVol] = buildScalarSPMArrays( ...
    Tvolume,'Structure','vertebra','LevelRange',levels);

[YcDiscVol, YkDiscVol, levelsDiscVol] = buildScalarSPMArrays( ...
    Tvolume, 'Structure','disc','LevelRange',levels);

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

% ---- VOLUME: Exporting summary arrays (vertebra and disc) ----
vertVol = struct(); vertVol.notes = 'Vertebra volume profile';
vertVol.levels = levelsVertVol; vertVol.axis = 'volume';
vertVol.measurement = 'volume'; vertVol.structure = 'vertebra';
exportSPMArray(sumPath, 'vertVol', YcVertVol, YkVertVol, vertVol);

discVol = struct(); discVol.notes = 'Disc volume profile';
discVol.levels = levelsDiscVol; discVol.axis = 'volume';
discVol.measurement = 'volume'; discVol.structure = 'disc';
exportSPMArray(sumPath, 'discVol', YcDiscVol, YkDiscVol, discVol);

%% MATLAB CLEANUP
% Clearing leftover workspace variables, except the measurement tables:
clearvars -except Tslice Theight Tvolume cfg;

clc; % clearing command window

