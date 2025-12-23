%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: main.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-23-2025
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

mainFile = matlab.desktop.editor.getActiveFilename; % path of 'main.m' file
srcPath = fileparts(mainFile); % directory path that holds 'main.m' file
projectPath = fileparts(srcPath); % morphologies repo path
cd(srcPath); % setting MATLAB repo to the 'main.m' repo

% Getting paths of vertebral and disc stl files:
stlDir = 'stl-geometries'; vertDir = 'vertebra-stls'; discDir = 'disc-stls';
stlPath = fullfile(projectPath, stlDir); % stl geometry path
vertPath = fullfile(stlPath, vertDir); % vertebrae geometry path
discPath = fullfile(stlPath, discDir); % disc geometry path

% Getting paths of utility functions:
genUtilsDir = 'gen-utils'; vertUtilsDir = 'vert-utils'; discUtilsDir = 'disc-utils';
genUtilPath = fullfile(srcPath, genUtilsDir); % stl geometry path
vertUtilPath = fullfile(srcPath, vertUtilsDir); % vertebrae geometry path
discUtilPath = fullfile(srcPath, discUtilsDir); % disc geometry path

% Adding paths of utility functions:
addpath(genUtilPath, vertUtilPath, discUtilPath);

%% PIPELINE CONFIGURATION
% Instead of scattering parameters across scripts, we can define them once
% and 'cfg' can be passed anywhere:
cfg = makeConfig();
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
%
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

%% MEASUREMENTS
