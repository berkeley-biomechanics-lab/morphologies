%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: setUtilPaths.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-25-2025
%
% Description: adding utility directory files into the MATLAB workspace 
% according to setup described in the README.md file at the head of the
% repo.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% IDENTIFYING UTILITY FILES
% Adding utility directory files into the MATLAB workspace 

% Getting directories of utility functions:
alignUtilsDir      = 'align-utils';
dataUtilsDir       = 'data-struct-utils';        
discConstrUtilsDir = 'disc-constr-utils'; 
geomMetaUtilsDir   = 'geom-meta-utils';     
plotUtilsDir       = 'plot-utils';               
slicerUtilsDir     = 'slicer-utils';          
genUtilsDir        = 'gen-utils';  

% Getting paths of utility functions:
alignUtilsPath = fullfile(srcPath, alignUtilsDir); 
dataUtilsPath = fullfile(srcPath, dataUtilsDir);
discConstrUtilsPath = fullfile(srcPath, discConstrUtilsDir); 
geomMetaUtilsPath = fullfile(srcPath, geomMetaUtilsDir);
plotUtilsPath = fullfile(srcPath, plotUtilsDir);
slicerUtilsPath = fullfile(srcPath, slicerUtilsDir);
genUtilPath = fullfile(srcPath, genUtilsDir);

% Adding paths of utility functions:
addpath(alignUtilsPath, dataUtilsPath, discConstrUtilsPath, ...
            geomMetaUtilsPath, plotUtilsPath, slicerUtilsPath, genUtilPath);

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

