%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the file path of a vertebra, this program measures the volume and
% surface area of the vertebra .stl file. 
% *(Assumes the geometry is closed and well defined)*
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc

% script variables:
varsbefore = who;

%% Computing 3D measurements

[F, V] = stlBinaryRead(filePath); % faces F and vertices V of .stl file
[vol, surfarea] = stlVolume(V', F'); % volume vol and surface area surfarea of .stl file

%% MATLAB cleanup

% deleting everything except areas and Z:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'vol', 'surfarea'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
