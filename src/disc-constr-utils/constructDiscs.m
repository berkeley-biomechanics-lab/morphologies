%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: constructDiscs.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 1-1-2025
%
% Description: constructing and exporting disc geometries via an endplate 
% extraction → surface lofting → stitching pipeline
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% DISC STL CONSTRUCTION
% Loading mesh data into 'subjectData'

% If 'true', then disc construction will be skipped:
alreadyMade = cfg.disc.alreadyMade;

% Skipping if measurements are already done:
if measurementsDone
    fprintf('Measurements have already done --> skipping disc construction!\n');
    return;
end

n = subjectData.numSubjects; % number of subjects

if ~alreadyMade
    tic; % starting rountine clock

    % If 'false', then disc levels that have already been exported will be 
    % skipped:
    overwriteDiscExports = cfg.overwrite.discExports;
    
    % Looping through each subject and building disc mesh data:
    for i = 1:n
    
        subjectName = subjectData.subject(i).name; % subject name
        centerline = subjectData.subject(i).centerline; % subject centerline
    
        % -----------------------------------------------------------
        % Build vertebra lookup table (one per subject)
        % -----------------------------------------------------------
        vMeshes = subjectData.subject(i).vertebrae.mesh;
        vNames  = [vMeshes.levelName];
    
        vMap = containers.Map(vNames, 1:numel(vNames));
    
        % -----------------------------------------------------------
        % Preallocate disc mesh array
        % -----------------------------------------------------------
        D = subjectData.subject(i).discs;
        nDiscs = D.numLevels;
    
        discMeshes = repmat(struct(), nDiscs, 1);
    
        % -----------------------------------------------------------
        % Build each disc using stored sup/inf info
        % -----------------------------------------------------------
        for d = 1:nDiscs
    
            discName = D.levelNames(d);
            discPath = D.levelPaths(d);
            supVertName = D.supVertNames(d);
            infVertName = D.infVertNames(d);
        
            % Safety check
            if ~isKey(vMap, supVertName) || ~isKey(vMap, infVertName)
                warning("Skipping disc %s (missing vertebra mesh).", ...
                        D.levelNames(d));
                continue;
            end
        
            supVertMesh = vMeshes(vMap(supVertName));
            infVertMesh = vMeshes(vMap(infVertName));
        
            % The following routines will construct an intervertebral disc 
            % volume between two adjacent vertebrae via a process of:
            %       1.) superior and inferior disc endplate extraction
            %       2.) endplate surface lofting
            %       3.) disc surface stitching and triangulation
            % ENDPLATE EXTRACTION: Obtaining disc endplates in the objects 
            % 'supDiscEnd' and 'infDiscEnd', which have the following fields:
            %       points: [N×3 double]
            %       faces:  [M×3 double]
            %       TR:     [M×3 triangulation]
            [supDiscEnd, infDiscEnd] = getEndplatesFromAdjacentVertebrae( ...
                supVertMesh, infVertMesh, centerline, cfg, d);
    
            % ENDPLATE LOFTING: Constructing intermediary exterior boundary
            % curves based on the boundary curves from the superior and
            % inferior endplate objects such that:
            %       Pk{1} → superior endplate
            %       Pk{end} → inferior endplate
            %       Pk{2:end-1} → bulged intermediate layers
            Pk = buildLoftCurves(supDiscEnd.Pb, infDiscEnd.Pb, cfg);
    
            % DISC STITCHING: Stitches the endplate and interior surfaces
            % together with the following high level strategy:
            %       1.) stacking all boundary points
            %       2.) creating quad strips between consecutive layers
            %       3.) splitting quads into triangles
            %       4.) merging with superior & inferior endplate triangulations
            %       5.) returning one triangulation object -->
            discTR = stitchDisc(Pk, supDiscEnd.TR, infDiscEnd.TR);
    
            % Exporting disc file:
            if ~exist(discPath, 'file') || overwriteDiscExports
                stlwrite(discTR, discPath);
            end
    
            % Monitoring disc construction process:
            monitorDiscEndplates = cfg.plot.monitorDiscEndplates; % getting config settings
            
            if monitorDiscEndplates
                % reusing figure for disc-by-disc construction process:
                if ~exist('constructionfig','var') || ~ishandle(constructionfig)
                    constructionfig = plotDiscMonitor(D, d, Pk, ...
                                                supDiscEnd, infDiscEnd, ...
                                                discTR, figure);
                else
                    constructionfig = plotDiscMonitor(D, d, Pk, ...
                                                supDiscEnd, infDiscEnd, ...
                                                discTR, constructionfig);
                end
            end
        end
    end
    fprintf('Disc construction done in %.2f seconds (%.2f minutes)!\n', toc, toc/60);
end

%% DISC STL METADATA PROCESSING
% Loading subjects' *disc mesh* data into 'subjectData'. NOTE: for this
% project, it is not assumed nor is it required that the disc mesh
% geometries will be watertight. Given some of the non-topological routines
% that are used to stitch the disc surfaces together, it is likely that
% disc meshes will NOT be watertight, and in this event, you'll see a
% warning. Future improvements to the workflow may involve making watertight
% and node conforming disc meshes based off of the vertebral body
% geometries. For now, we will continue with these "proxy" discs.

% Looping through each subject's '.discs' field and appending mesh
% metadata:
for i = 1:n

    % Getting ith subject's vertebra collection data:
    d = subjectData.subject(i).discs;
    subjectName = subjectData.subject(i).name;

    % Getting level paths and names of ith subject's vertebrae:
    levelPaths = d.levelPaths;
    levelNames = d.levelNames;

    % Extracting mesh properties of ith subject's vertebrae:
    meshes = loadSTLCollection(levelPaths, levelNames, subjectName);

    % Appending metadata into 'subjectData'
    subjectData.subject(i).discs.mesh = meshes;
end

%% VISUALIZATION
% Plotting each subjects' discs

showDiscMetadata = cfg.plot.showDiscMetadata; % getting config settings

% Skipping visualization if 'showSubjectVertebrae' = false:
if showDiscMetadata
    % Looping through each subject:
    for j = 1:n
        % Visualizing discal properties for a single subject:
        plotDiscs(subjectData.subject(j));
    end
end

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

