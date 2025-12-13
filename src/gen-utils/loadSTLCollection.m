function meshes = loadSTLCollection(levelPaths, levelNames, subjectName)
% Loads stl files and returns a struct array of mesh metadata
%
% Inputs:
%   levelPaths  (1×N string)  paths to STL files
%   levelNames  (1×N string)  vertebra level names (e.g., "T7","L2")
%
% Output:
%   meshes (1×N struct) with fields:
%       .levelName
%       .TR
%       .centroid
%       .numVertices
%       .numFaces
%       .isWatertight

    n = numel(levelPaths);

    % Safety check
    if numel(levelNames) ~= n
        error("levelPaths and levelNames must have the same length.");
    end

    % Preallocate struct array
    meshes(n) = struct( ...
        'levelName', "", ...
        'TR', [], ...
        'centroid', [], ...
        'numVertices', [], ...
        'numFaces', [], ...
        'isWatertight', [] );

    for k = 1:n
        TR = stlread(levelPaths(k));

        meshes(k).levelName    = levelNames(k);
        meshes(k).TR           = TR;
        meshes(k).centroid     = mean(TR.Points, 1);
        meshes(k).numVertices  = size(TR.Points, 1);
        meshes(k).numFaces     = size(TR.ConnectivityList, 1);
        meshes(k).isWatertight = isempty(freeBoundary(TR));

        if ~meshes(k).isWatertight
            warning("Level %s, subject %s is not watertight!", levelNames(k), subjectName);
        end
    end
end

