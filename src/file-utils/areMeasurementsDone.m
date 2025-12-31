%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: areMeasurementsDone.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-30-2025
%
% Description: looping through each subjects' 'measurement' field and
% checking if all the appropriate slicer, height, and volume measurements
% have been made and exported accordingly
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

warning('off','all') % turning on warnings

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% CHECKING MEASURMENT EXPORTS
% Checking if the slicer, height, and volume measurements have been made
% and exported to the 'data/measurements' directory. The design is absolute
% in that if any of the slicer, height, and volume measurements for any of 
% the vertebrae and disc bodies are incomplete, all measurements will be
% completely redone and exported. This measurement state will be captured
% by the 'measurementsDone' boolean variable.

% Measurements are assumed to be complete until proven otherwise:
measurementsDone = true;

% Checking overwriting setting:
if cfg.overwrite.measures
    measurementsDone = false;
    fprintf("Overwriting all existing measurements!\n");
else
    % Looping through each subject:
    for i = 1:subjectData.numSubjects
        subj = subjectData.subject(i);
    
        % If subject i has not been written or incomplete, then
        % measurements will be remade:
        if shouldRunMeasurements(subj, cfg)
            measurementsDone = false;
            return; % stopping the for loop if any subject measurements needs to be rewritten
        end
    end
end

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'measurementsDone'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

