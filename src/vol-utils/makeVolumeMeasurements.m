%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: makeVolumeMeasurements.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-30-2025
%
% Description: measuring the volumes of all the subjects' goemetries 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

warning('off','all') % turning on warnings

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% COMPUTING VOLUME
% Measuring each subjects' vertebrae and discs volume

% Skipping if measurements are already done:
if measurementsDone
    fprintf('Volume measurements already done!\n');
else
    % --- Volume tracking ---
    job.total = 0;
    if cfg.measurements.makeVertebraVols
        job.total = job.total + sum(arrayfun(@(s) s.vertebrae.numLevels, subjectData.subject));
    end
    if cfg.measurements.makeDiscVols
        job.total = job.total + sum(arrayfun(@(s) s.discs.numLevels, subjectData.subject));
    end
    job.count = 0;
    
    tic;
    % Looping through each subject:
    for i = 1:subjectData.numSubjects
        subj = subjectData.subject(i);
    
        job.subjectIdx  = i;
        job.numSubjects = subjectData.numSubjects;
    
        % Vertebra slices:
        if cfg.measurements.makeVertebraVols
            job.levelIdx = 0;
            [subjectData.subject(i).vertebrae.measurements.vol, job] = ...
                getVolumeGeometrySet(subj.vertebrae, job);
        end
    
        % Disc slices:
        if cfg.measurements.makeDiscVols
            job.levelIdx = 0;
            [subjectData.subject(i).discs.measurements.vol, job] = ...
                getVolumeGeometrySet(subj.discs, job);
        end
    end
    fprintf('Volume measurements done in %.2f seconds (%.2f minutes)!\n', toc, toc/60);
end

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

