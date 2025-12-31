%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: makeHeightMeasurements.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-30-2025
%
% Description: measuring the 2D height distribution and corresponding 1D AP
% and lateral height distributions associated with the re-aligned Z-axis of
% the subjects' geometries
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

warning('off','all') % turning on warnings

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% CHARACTERIZING HEIGHT GRID
% Discretizing each subjects' vertebra and disc geometry and using
% ray-intersections to determine the 1D and 2D height distributions

% Skipping if measurements are already done:
if measurementsDone
    fprintf('Height measurements already done!\n');
else
    % --- Height ray tracking ---
    job.total = 0;
    if cfg.measurements.makeVertebraHeights
        job.total = job.total + sum(arrayfun(@(s) s.vertebrae.numLevels, subjectData.subject));
    end
    if cfg.measurements.makeDiscHeights
        job.total = job.total + sum(arrayfun(@(s) s.discs.numLevels, subjectData.subject));
    end
    job.count = 0;
    
    tic;
    % Looping through each subject:
    for i = 1:subjectData.numSubjects
        subj = subjectData.subject(i);
    
        job.subjectIdx  = i;
        job.numSubjects = subjectData.numSubjects;
    
        % Vertebra heights:
        if cfg.measurements.makeVertebraHeights
            job.levelIdx = 0;
            [subjectData.subject(i).vertebrae.measurements.height, job] = ...
                        getHeightGeometrySet(subj.vertebrae.mesh, cfg, job);
        end
    
        % Disc heights:
        if cfg.measurements.makeDiscHeights
            job.levelIdx = 0;
            [subjectData.subject(i).discs.measurements.height, job] = ...
                        getHeightGeometrySet(subj.discs.mesh, cfg, job);
        end
    end
    fprintf('Height measurements done in %.2f seconds (%.2f minutes)!\n', toc, toc/60);
end

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

