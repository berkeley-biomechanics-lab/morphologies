%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: main.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-31-2025
%
% Description: main pipeline for spinal morphology measurement project
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; % clearing command window and workspace variables

set(0,'DefaultFigureWindowStyle','docked') % docking figures
warning('on','all') % turning on warnings

format compact; % suppressing blank lines and decreasing spacing in the CW

%% DIRECTORY INFORMATION
% Storing names of all necessary directories. ASSUMPTION: directories and 
% stl geometry files are configured according to setup described in the 
% README.md file at the head of the repo.

% Identifying the head MATLAB execution file:
mainFile = matlab.desktop.editor.getActiveFilename; % path of 'main.m' file
srcPath = fileparts(mainFile); % directory path that holds 'main.m' file
projectPath = fileparts(srcPath); % morphologies repo path
cd(srcPath); % setting MATLAB repo to the 'main.m' repo

% Now that the head MATLAB execution file has been identified, the
% supplementary utility files will be identified here:
setUtilPaths; % adding supplementary directory files into MATLAB workspace

%% PIPELINE CONFIGURATION
% Instead of scattering parameters across scripts, we can define them once
% and 'cfg' can be passed anywhere:
cfg = makeConfig(projectPath);
validateConfig(cfg)

%% SUBJECT INFORMATION
% Initializing the porcine subject data structure

% 'subjectData' is a struct that stores the necessary data associated
% with the study, including the # of subjects, # of kyphotic subjects,
% # of control subjects, etc. It also includes the 'subject' struct array
% that stores subject-specific data as such:
%       subjectData.subject(1). ...
%       subjectData.subject(2). ...
%       ...
%       subjectData.subject(N). ..., 
% where N refers to the number of subjects and each subject has the 
% following fields and subfields:
%             ┣ subject(i).name = "..."
%             ┣ subject(i).isKyphotic = boolean
%             ┣ subject(i).vertebrae
%                       ┣ .vertebrae.levelNames = ["Lvl1", "Lvl2", ...]
%                       ┣ .vertebrae.levelPaths = ["pathtoLvl1", "pathtoLvl2", ...]
%                       ┣ .vertebrae.numLevels = X
%                       ┣ ...
%                       ┣ .vertebrae.measurements
%                                   ┣ .measurements.csas
%                                   ┣ .measurements.heights
%                                   ┣ .measurements.volumes
%                                   ┣ ...
%             ┣ subject(i).discs
%                       ┣ .discs.levelNames = ["Lvl1", "Lvl2", ...]
%                       ┣ .discs.levelPaths = ["pathtoLvl1", "pathtoLvl2", ...]
%                       ┣ .discs.numLevels = Y
%                       ┣ ...
%                       ┣ .discs.measurements
%                               ┣ .measurements.csas
%                               ┣ .measurements.heights
%                               ┣ .measurements.volumes
%                               ┣ ...
% Notes about pipeline data structure:
%    --> 'subjectData' is the parent struct and 'subject' is the child
%        struct
%    --> The convention of this pipeline will be that the 'subject'
%        field inside of 'subjectData' will be a copy of the 'subject'
%        workspace variable. Thus, to edit or add subject-specific data
%        into the workspace, the convention will be to modify the workspace
%        variable 'subject' directly and *always* reassign to 'subjectData'
%        after modification.
%               --> This same convention will be used for any other
%                   parent-child structs in the pipeline.
%    --> This is to avoid having to modify the 'subjectData' struct
%        directly every single time a change is made.
% Subsequently, we describe the level names, file paths, and number of 
% levels associated with each subjects' vertebrae and discs given the
% user-defined settings and append this information into 'subjects' using
% the following subroutine:
setSubjectInformation; % constructs and initializes 'subjectData' data structure

% Checking if the slicer, height, and volume measurements have been made
% and exported to the 'data/measurements' directory:
areMeasurementsDone; % returns boolean 'measurementsDone'

%% GEOMETRY PROPERTIES
% Appending vertebral body, disc, and centerline geometry features into 
% 'subjectData' data structure

% Plotting and loading vertebral body mesh features into 'subjectData':
loadGeometryMetadata; % appends geometry and centerline metadata into 'subjectData'

%% DISC CONSTRUCTION PROCESS
% Now that all of the vertebral geometry has been processed and the
% preliminary discal information has been appended into 'subjectData', the
% pipeline will proceed to automatically constructing the disc geometries
% between all of the adjacent vertebral body layers. The pipeline will
% create these disc geometries in a three-step process:
%       1.) Endplate extraction: characterizing the geometries of the 
%           superior and inferior surfaces of the discs based on its two 
%           adjacent vertebral bodies.
%       2.) Surface lofting: connecting the endplate geometries to form a
%           closed disc volume.
%       3.) Stitching and triangulation: stitching the endplate and 
%           interior surfaces together.

% Constructing and exporting disc geometries via an endplate extraction → 
% surface lofting → stitching pipeline. Check 'cfg.disc.alreadyMade' and 
% 'cfg.overwrite.discExports' settings to see routine configuration setup:
constructDiscs; % appends disc metadata into 'subjectData'

%% ALIGNMENT
% Centering and rotating the geometric bodies into a common Cartesian 
% coordinate frame defined by the standard orthonormal basis

% Aligning the vertebral bodies and discs to a common reference frame:
alignGeometries; % appends alignment metadata into 'subjectData'

%% MEASUREMENTS
% Accessing morphologies and making measurements of all geometric bodies

% Now that all of the necessary and subject-specific processing has taken
% place, the routine will now populate the 'subjectData' struct with the
% geometric measurements associated with each body. The type of
% measurements include cross sectional area (in the XY, YZ, XZ planes),
% height (2D distribution between the inferior-superior endplates), volume,
% etc, all of which will initially be stored in 'subjectData' in each of
% the respective '.subject.{vertebrae,discs}' fields under the field of
% '.measurements'.

% Populating the '.measurements' field with the measurements associated 
% with the cross sectional (CS) slicer routine:
makeSlicerMeasurements; % populates 'subjectData' with slicer-based measurements

% Populating the '.measurements' field with height measurements:
makeHeightMeasurements; % populates 'subjectData' with height-based measurements

% Populating the '.measurements' field with volume measurements:
makeVolumeMeasurements; % populates 'subjectData' with volume-based measurements

%% EXPORTING
% Writing subject specific data to the 'data/raw' directory

% 'data/raw' directory will be populated with 'XXX.mat' files,
% where 'XXX' refers to the subject name (ID) of each porcine subject:
exportData; % if measurements are not done or set to be written, files will be written here

% Clearing leftover workspace variables, using only the 'data/measurements'
% files for the analysis section:
clearvars -except cfg;

%% ANALYSIS
% Displaying raw measurement data in 'data/measurements' and comparing 
% kyphotic and normative experimental groups

% Summarizing all subject data into easy-to-use data structures, and 
% visualizing the summarized raw data:
summarizeData; % visualizes raw data and exports for SPM analysis

