%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: main.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-10-2025
%
% Description: main pipeline for spinal morphology measurement project
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; % clearing command window and workspace variables

set(0,'DefaultFigureWindowStyle','docked') % docking figures
warning('off','all') % turning off warnings

format compact; % suppressing blank lines and decreasing spacing in the CW

%% DIRECTORY INFORMATION
% storing names of all necessary directories
%
% ASSUMPTION: directories and stl geometry files are configured according 
% to setup described in the README.md file at the head of the repo.

projectPath = fileparts(pwd); % morphologies repo path

% Getting paths of vertebral and disc stl files:
stlDir = 'stl-geometries'; % name of stl geometry directory
vertDir = 'vertebra-stls'; % name of vertebrae geometry directory
discDir = 'disc-stls'; % name of disc geometry directory

stlPath = fullfile(projectPath, stlDir); % stl geometry path
vertPath = fullfile(stlPath, vertDir); % vertebrae geometry path
discPath = fullfile(stlPath, discDir); % disc geometry path

%% SUBJECT INFORMATION
% initializing the porcine subject data structure
 
% 'subjectData' is a struct that stores the necessary data associated
% with the study, including the # of subjects, # of kyphotic subjects,
% # of control subjects, etc. It also includes the 'subject' struct array
% that stores subject-specific data as such:
%       subjectData.subject(1). ...
%       subjectData.subject(2). ...
%       ...
%      subjectData.subject(N). ..., 
% where N refers to the number of subjects and each subject has the 
% following fields and subfields:
%             ┣ subject(i).name = "..."
%             ┣ subject(i).isKyphotic = boolean
%             ┣ subject(i).vertebrae
%                       ┣ .vertebrae.levelNames
%                       ┣ .vertebrae.levelPaths
%                       ┣ .vertebrae.numLevels
%                       ┣ .vertebrae.measurements
%                                   ┣ .measurements.csas
%                                   ┣ .measurements.heights
%                                   ┣ .measurements.volumes
%                                   ┣ ...
%             ┣ subject(i).discs
%                       ┣ .discs.levelNames
%                       ┣ .discs.levelPaths
%                       ┣ .discs.numLevels
%                       ┣ .discs.measurements
%                               ┣ .measurements.csas
%                               ┣ .measurements.heights
%                               ┣ .measurements.volumes
%                               ┣ ...

% Before intializing the 'subject' data structure, we must manually provide
% some information to get us started. 
% 
% ASSUMPTION: the data is structured such that each subject has a unique 
% 3-digit name and kyphotic state associated with it. Therefore, we
% classify these subjects' datas here:
subjectNames = ["643", "658", "660", "665", "666", "717", "723", ...
                        "735", "743", "764", "765", "766", "778", "779"];
subjectStates = [false, true, true, true, true, false, false, ...
                        true, false, true, true, true, false, false];

% Initializing subjects structure, with names and states:
subject = struct('name', num2cell(subjectNames), ...
                    'isKyphotic', num2cell(subjectStates));

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
numSubjects = length(subjectNames); % number of porcine subjects
numKyphoticSubjects = sum(subjectStates); % number of kyphotic porcine subjects
numControlSubjects = sum(~subjectStates); % number of control porcine subjects
subjectData = struct('numSubjects', numSubjects, ...
                        'numKyphoticSubjects', numKyphoticSubjects, ...
                        'numControlSubjects', numControlSubjects, ...
                        'subject', subject);

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

% The user must also specify whether or not they wish to overwrite the
% measurement process with the boolean variable 'overwrite'. This means if
% the measurements for a particular level have already been made,
% processed, and written and 'overwrite' = false, then this level will be
% skipped.
overwrite = true;

% Subsequently, we describe the level names, file paths, and number of 
% levels associated with each subjects' vertebrae and discs given the
% user-defined settings and append this information into 'subjects' using
% the following subroutine.
getLevelsInformation;

% UNDER CONSTRUCTION -->
% [develop procedure that automates filling in the file path locations for
% the vertebrae and disc files. Disc file paths can be deterministically
% found based on the vertebrae files.]
