%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: loadGeometryMetadata.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 6-24-2026
%
% Description: loading and characterizing stl properties from the vertebral
% body mesh geometries and describing vertebral, discal, and centerline
% features
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% VERTEBRA STL METADATA PROCESSING
% Loading subjects' *vertebral mesh* data into 'subjectData'

% If 'true', then disc construction will be skipped:
alreadyMade = cfg.disc.alreadyMade;

% If 'true', then disc exports will be overwritten:
overwriteDiscExports = cfg.overwrite.discExports;

% Skipping if measurements are already done or if disc exports are still to
% be made:
if measurementsDone && (alreadyMade && ~overwriteDiscExports)
    fprintf('Measurements are already done, discs are already made, and will not be overwritten --> skipping goemetry metadata processing!\n');
    return;
end

% Starting rountine clock:
tic;

n = subjectData.numSubjects; % number of subjects

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

%% SUBJECT SPINE METADATA PROCESSING
% Loading subjects' *centerline* data into 'subjectData'

% Looping through each subject's '.vertebrae.mesh' field and appending
% centerline spline properties into 'subject(i).centerline':
for i = 1:n
    % Computing a smooth spinal centerline from vertebral centroids:
    subjectData.subject(i).centerline = ...
            computeSpineCenterline(subjectData.subject(i).vertebrae);
end

% Secondary loop to compute centerline tangent properties at each vertebral
% centroid and appending into 'subject(i).centerline':
for i = 1:n
    % Computing unit tangent at subject i's vertebral centroids:
    subjectData.subject(i).centerline = ...
            computeCenterlineTangents(subjectData.subject(i));
end

%% DISC SPINE METADATA PROCESSING
% Loading subjects' *disc* data into 'subjectData'

% Looping through each subject and appending disc centerline spline 
% properties into 'subject(i).centerline':
for i = 1:n
    % Building disc centerline properties from subject i's 'vertebrae' and 
    % 'centerline' fields:
    subjectData.subject(i).centerline = ...
                computeDiscCenterline(subjectData.subject(i));
end

%% VISUALIZATION
% Plotting each subjects' vertebral bodies

showGeometryMetadata = cfg.plot.showGeometryMetadata; % getting config settings

% Skipping visualization if 'showSubjectVertebrae' = false:
if showGeometryMetadata
    % Looping through each subject:
    for j = 1:n
        % Visualizing subject geometric properties for a single subject:
        plotSubject(subjectData.subject(j));
    end
end
fprintf('Loading geometry done in %.2f seconds (%.2f minutes)!\n', toc, toc/60);

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

