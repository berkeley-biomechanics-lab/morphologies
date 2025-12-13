%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: loadVertebrae.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-12-2025
%
% Description: loading and characterizing stl properties from the vertebral
% body mesh geometries 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% VERTEBRA STL METADATA PROCESSING
% Loading mesh data into 'subjectData'

n = length(subjectData.subject); % number of subjects

% Looping through each subject's '.vertebrae' field and appending mesh
% metadata:
for i = 1:n

    % Getting ith subject's vertebra collection data:
    v = subjectData.subject(i).vertebrae;
    subjectName = subjectData.subject(i).name;

    % Getting level paths and names of ith subject's vertebrae:
    levelPaths = v.levelPaths;
    levelNames = v.levelNames;

    % Extracting mesh properties of ith subject's vertebrae:
    meshes = loadSTLCollection(levelPaths, levelNames, subjectName);

    % Appending metadata into 'subjectData'
    subjectData.subject(i).vertebrae.mesh = meshes;
end

%% VISUALIZATION
% Plotting each subjects' vertebral bodies

% Skipping visualization if 'showSubjectVertebrae' = false:
if showSubjectVertebrae
    % Looping through each subject:
    for j = 1:n
        % Plotting all vertebra meshes for a single subject:
        plotSubjectVertebrae(subjectData.subject(j));
    end
end

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

