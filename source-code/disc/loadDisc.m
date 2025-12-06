%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the subject name and disc level, this program loads the
% appropriate .stl file and then extracts and centers its geometry data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% script variables:
varsbefore = who;

%% STL processing

% getting path of .stl file:
stlPath = discFilePath;

% opening .stl file:
TR = stlread(stlPath); % returns triangulation object containing the triangles defined in STL file
model.vertices = TR.Points; % initializing 'model' object
model.faces = TR.ConnectivityList;
P = TR.Points; % size = [np, 3]

% centering:
c = mean(P); % size = [1, 3]
Pc = P - c; % size = [np, 3]

% defining c1 translation vector:
c1 = c;

%% MATLAB cleanup

% deleting everything except Pc and model:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'Pc', 'model', 'c1', 'P'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})


