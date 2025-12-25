%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: setSubjectInformation.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-23-2025
%
% Description: getting the file paths, level names, and number of 
% levels associated with each subjects' vertebrae and discs given the
% user-defined settings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% INITIALIZING SUBJECT INFORMATION
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
measuredLevels = cfg.subjects.measuredLevels;

% By the same token, we wish to classify which of the availible subjects
% we'd like to involve in the measurement pipeline. The user must define
% which of the subjects from 'subjectNames' they would like to measure in 
% the following two formatting options:
%           1.) Measure all subjects: "all"
%           2.) Measure specific subjects: ["643", "666", "717", ...]
% Default settings will be:
%       --> Subjects: "all"
measuredSubjects = cfg.subjects.measuredSubjects;

%% CHECKING MEASUREDLEVELS VARIABLE AND GETTING DESIRED VERTEBRA LEVELS
% Checking to see if the user-defined 'measuredLevels' variable has been
% defined appropriately, valid formats of 'measuredLevels' include:
%       1) "all"
%       2) "L1 - L6"         (range)
%       3) ["T1","T5",...]   (list)

% Validating format of 'measuredLevels' and getting the associated
% desired vertebral levels to-be-measured:
selectedLevels = getLevelSelection(measuredLevels, allLevelNames);

%% CHECKING MEASUREDSUBJECTS VARIABLE AND GETTING DESIRED SUBJECTS
% Ohecking to see if the user-defined 'measuredSubjects' variable has been
% defined appropriately, valid formats of 'measuredSubjects' include:
%       1) "all"
%       3) ["643", "666", "717", ...]   (list)

% Validating format of 'measuredSubjects' and getting the associated
% desired subjects to-be-measured:
selectedSubjects = getSubjectSelection(measuredSubjects, allSubjectNames);

%% SETTING DATA OF VERTEBRA LEVEL PROPERTIES FOR EACH SUBJECT
% Organizing vertebral datas and constructing 'subject' data struct 

% Getting paths of vertebral and disc stl files:
stlDir = 'stl-geometries'; vertDir = 'vertebra-stls'; discDir = 'disc-stls';
stlPath = fullfile(projectPath, stlDir); % stl geometry path
vertPath = fullfile(stlPath, vertDir); % vertebrae geometry path
discPath = fullfile(stlPath, discDir); % disc geometry path

% Getting array of vertebral data structs, one per subject, in 
% 'vertebraSTLData' and string array of selected subject names in
% 'subjectNames':
[vertebraData, subjectNames] = getVertebraInformation(vertPath, ...
                                                    selectedSubjects, ...
                                                    selectedLevels);

% Using the subject name --> subject state dictionary to get the kyphotic
% states of the corresponding subjects in 'subjectNames':
subjectStates = subjectDict(subjectNames);

% Initializing subjects structure, with names and states:
subject = struct('name', num2cell(subjectNames), ...
                    'isKyphotic', num2cell(subjectStates));

% Storing vertebral data in the 'subject' structure:
for i = 1:length(subject)
    subject(i).vertebrae = vertebraData(i).vertebrae;
end

%% SETTING DATA OF DISC LEVEL PROPERTIES FOR EACH SUBJECT
% Organizing disc datas and file infrastructures and appending new 
% information to 'subject' data struct

% Writing paths of subject name directories onto 'discPath' and skipping if
% subject repo already exists:
for s = subjectNames
    folderPath = fullfile(discPath, s);
    if ~exist(folderPath, "dir")
        mkdir(folderPath);
    end
end

% Working on storing disc data:
discData = getDiscInformation(discPath, vertebraData, allLevelNames);

% Storing vertebral data in the 'subject' structure:
for i = 1:length(subject)
    subject(i).discs = discData(i).discs;
end

%% BUILDING PIPELINE DATA STRUCTURE
% Contructing 'subjectData' struct with global subject properties and
% already-contructed 'subject' struct:
numSubjects = length(subject); % number of porcine subjects
numKyphoticSubjects = sum(subjectStates); % number of kyphotic porcine subjects
numControlSubjects = sum(~subjectStates); % number of control porcine subjects
subjectData = struct('numSubjects', numSubjects, ...
                        'numKyphoticSubjects', numKyphoticSubjects, ...
                        'numControlSubjects', numControlSubjects, ...
                        'subject', subject);

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'subjectData'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

