%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: main.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-12-2025
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
% Before intializing the 'subject' data structure, we must manually provide
% some information to get us started. ASSUMPTION: the data is structured 
% such that each subject has a unique 3-digit name and kyphotic state 
% associated with it. Therefore, we classify these subjects' datas here:
allSubjectNames = ["643", "658", "660", "665", "666", "717", "723", ...
                        "735", "743", "764", "765", "766", "778", "779"];
allSubjectStates = [false, true, true, true, true, false, false, ...
                        true, false, true, true, true, false, false];
allLevelNames = ["T1", "T2", "T3", "T4", "T5", "T6", "T7", ...
                    "T8", "T9", "T10", "T11", "T12", "T13", "T14", ...
                    "T15", "L1", "L2", "L3", "L4", "L5", "L6"];

% Subject name --> subject state dictionary object:
subjectDict = dictionary(allSubjectNames, allSubjectStates);

% Next, we wish to classify which of the availible vertebra levels we'd
% like to involve in the measurement pipeline. It is assumed that each
% porcine subject has a maximum of 21-segmentable levels (15 thoracic and 6 
% lumbar), of which >= 21 are available in the 'vertPath' directory. The
% user must define which of the 21 levels they would like to measure in the
% following three formatting options:
%           1.) Measure all levels: "all"
%           2.) Measure levels that lie in a certain interval:
%                   "[upper level] - [lower level]" (Example: "L1 - L6")
%           3.) Measure specific levels: ["T2", "T5", "T10", ...]
% The selection of vertebra levels will also determine the selection of
% disc levels. For example, if the vertebra levels "L1 - L6" are chosen,
% then the associated disc levels to be processed are "L1-L2 - L5-L6".
%
% Default settings will be:
%       --> Levels: "all"
measuredLevels = "all";

% By the same token, we wish to classify which of the availible subjects
% we'd like to involve in the measurement pipeline. The user must define
% which of the subjects from 'subjectNames' they would like to measure in 
% the following two formatting options:
%           1.) Measure all subjects: "all"
%           2.) Measure specific subjects: ["643", "666", "717", ...]
% Default settings will be:
%       --> Subjects: "all"
measuredSubjects = "all";

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
setSubjectInformation; % returns 'subject', 'subjectStates'

% Contructing 'subjectData' struct with global subject properties and
% already-contructed 'subject' struct:
numSubjects = length(subject); % number of porcine subjects
numKyphoticSubjects = sum(subjectStates); % number of kyphotic porcine subjects
numControlSubjects = sum(~subjectStates); % number of control porcine subjects
subjectData = struct('numSubjects', numSubjects, ...
                        'numKyphoticSubjects', numKyphoticSubjects, ...
                        'numControlSubjects', numControlSubjects, ...
                        'subject', subject);

%% VERTEBRAL GEOMETRY MESH PROPERTIES
% Appending vertebral body geometry mesh features into the 'subjectData'
% data structure like so:
%       subjectData.subject(i).vertebrae.mesh(j)
%             ┣ mesh(j).TR = TR
%             ┣ mesh(j).numVertices = size(TR.Points, 1);
%             ┣ mesh(j).numFaces = size(TR.ConnectivityList, 1);
%             ┣ mesh(j).isWatertight = isempty(freeBoundary(TR));
%             ┣ mesh(j).centroid = [X, Y, Z];
%             ┣ ...

% Plotting and loading vertebral body mesh features into 'subjectData':
showSubjectVertebrae = false; % if 'false', mesh plots will be skipped
loadVertebrae; % appends mesh metadata into 'subjectData'

%% OVERWRITE PROPERTIES
% The user must also specify whether or not they wish to overwrite the
% measurement process with the boolean variable 'overwriteMeasures'. This 
% means if the measurements for a particular level have already been made,
% processed, and written and 'overwriteMeasures' = false, then this level 
% will be skipped.
%
% The measurement pipeline also includes an automated disc construction
% process that models the IVD as the empty space in between the inferior
% and superior vertebrae. These discs geometry will be created and exported
% into stl files onto 'discPath'. If 'overwriteDiscExports' = false, then
% disc levels that have already been exported will be skipped.
overwriteMeasures = true;
overwriteDiscExports = true;

%% DISC CONSTRUCTION PROCESS
% [Under construction]

