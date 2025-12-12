%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: setSubjectInformation.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-11-2025
%
% Description: getting the file paths, level names, and number of 
% levels associated with each subjects' vertebrae and discs given the
% user-defined settings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

% Getting workspace variables at the start of the new script:
varsbefore = who;

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

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'subjectNames', 'subjectStates', 'subject'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

