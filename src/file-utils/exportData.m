%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: exportData.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-30-2025
%
% Description: writing subject specific data to the 'data/measurements' 
% directory (if measurements are not done or set to be overwritten)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

warning('off','all') % turning on warnings

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% EXPORTING EACH SUBJECT
% Each subject gets its own data file written at the 'data/measurements' 
% directory

% Checking if measurements are not done or set to be overwritten:
if cfg.overwrite.measures || ~measurementsDone
    % Looping through each subject:
    for i = 1:subjectData.numSubjects
        subj = subjectData.subject(i);
    
        % Write to 'data/measurements' directory:
        writeSubjectData(subj, cfg);
    end
    fprintf("Subjects have been written to 'data/measurements' directory!\n");
end

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

