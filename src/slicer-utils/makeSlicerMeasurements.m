%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: makeSlicerMeasurements.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-25-2025
%
% Description: slicing through the subjects' goemetries through the three
% standard coordinate axes and measuring the associated geometric features
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

warning('off','all') % turning on warnings

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% VERTEBRAE SLICING
% Slicing through each subjects' vertebrae geometry and appending the
% associated measurement data to 'subject.vertebrae..."

n = subjectData.numSubjects; % number of subjects
numSlices = cfg.measurements.numSlices; % slicer frequency
slicerIgnorance = cfg.measurements.slicerIgnorance; % how much of the inferior and superior slices will be ignored

makeVertebraSlices = cfg.measurements.makeVertebraSlices; % if 'false', vertebra slices will be skipped
makeDiscSlices = cfg.measurements.makeDiscSlices; % if 'false', disc slices will be skipped

% --- Progress tracking ---
totalJobs = 0;
if makeVertebraSlices
    totalJobs = totalJobs + sum(arrayfun(@(s) s.vertebrae.numLevels, subjectData.subject));
end
if makeDiscSlices
    totalJobs = totalJobs + sum(arrayfun(@(s) s.discs.numLevels, subjectData.subject));
end
jobCount  = 0;

tic
% Looping through each subject:
if makeVertebraSlices
    for i = 1:n
    
        subj = subjectData.subject(i); % ith subject
        numLevels = subj.vertebrae.numLevels; % # of disc levels
    
        % Preallocate struct array
        measurements = repmat(struct( ...
                                'csa', struct('X',[],'Y',[],'Z',[]), ...
                                'widths', struct('X',[],'Y',[],'Z',[])), ...
                                numLevels,1);
    
        % Looping through each vertebra of subject i:
        for v = 1:numLevels
    
            jobCount = jobCount + 1;
            pct = 100 * jobCount / totalJobs;
            nbytes = fprintf(['Slicer measurements progress: ' ...
                        'Subject %d/%d | Vertebra %d/%d | %5.1f%% complete\r'], ...
                        i, n, v, subj.vertebrae.numLevels, pct);
    
            % Getting vertebra mesh properties:
            vMesh = subj.vertebrae.mesh(v);
    
            V = vMesh.alignedProperties.Points; % aligned points
            F = vMesh.alignedProperties.Faces; % faces aligned points
            
            vert.vertices = V;
            vert.faces    = F;
    
            % Geometric limits:
            bbox = [min(V,[],1); max(V,[],1)]'; % (3x2) bounding box of geometry
    
            % Slice locations along {x,y,z} axes:
            sx = linspace(bbox(1,1), bbox(1,2), numSlices);
            sy = linspace(bbox(2,1), bbox(2,2), numSlices);
            sz = linspace(bbox(3,1), bbox(3,2), numSlices);
    
            % Defining sets of three anatomical planes:
            [Px, Py, Pz] = makeAllPlanes(sx, sy, sz, bbox);
    
            % Looping through slices for all three anatomical planes:
            for k = 1:numSlices
                % --- Slice mesh with each plane ---
                slices = sliceAllAxes(vert, Px(k), Py(k), Pz(k), k/numSlices, slicerIgnorance);
    
                % --- Measurement outputs ---
                measures.csa.X(k) = slices.X.area;
                measures.csa.Y(k) = slices.Y.area;
                measures.csa.Z(k) = slices.Z.area;

                measures.widths.X(k,:) = slices.X.widths.w;
                measures.widths.Y(k,:) = slices.Y.widths.w;
                measures.widths.Z(k,:) = slices.Z.widths.w;

                % Erase the previous line using the stored length
                fprintf(repmat('\b', 1, nbytes));
                nbytes = fprintf(['Slicer measurements progress: ' ...
                        'Subject %d/%d | Vertebrae %d/%d | %5.1f%% progress | %5.1f%% complete \r'], ...
                        i, n, v, subj.vertebrae.numLevels, pct, k/numSlices * 100);
            
                % --- Live visualization ---
                monitorVertebraSlices = cfg.plot.monitorVertebraSlices; % getting config settings
                
                % Monitoring vertebra slicer measurement process:
                if monitorVertebraSlices
                    % reusing figure for slicing process:
                    if ~exist('slicesfig','var') || ~ishandle(slicesfig)
                        slicesfig = plotSliceMonitor(vMesh, slices, k, cfg, measures, figure);
                    else
                        slicesfig = plotSliceMonitor(vMesh, slices, k, cfg, measures, slicesfig);
                    end
                end
            end
    
            % Appending 'measures' to 'measurements' struct:
            measurements(v) = measures;
        end
    
        clc; % clearing progress bar after each subject has been processed
    
        % Appending 'measurements' to 'subjectData' struct:
        subjectData.subject(i).vertebrae.measurements = measurements;
    end
end

%% DISC SLICING
% Slicing through each subjects' discs geometry and appending the
% associated measurement data to 'subject.discs..."

% Looping through each subject:
if makeDiscSlices
    for i = 1:n
    
        subj = subjectData.subject(i); % ith subject
        numLevels = subj.discs.numLevels; % # of disc levels
    
        % Preallocate struct array
        measurements = repmat(struct( ...
                                'csa', struct('X',[],'Y',[],'Z',[]), ...
                                'widths', struct('X',[],'Y',[],'Z',[])), ...
                                numLevels,1);
    
        % Looping through each disc of subject i:
        for d = 1:numLevels
    
            jobCount = jobCount + 1;
            pct = 100 * jobCount / totalJobs;
            nbytes = fprintf(['Slicer measurements progress: ' ...
                        'Subject %d/%d | Disc %d/%d | %5.1f%% complete\r'], ...
                        i, n, d, subj.discs.numLevels, pct);
    
            % Getting disc mesh properties:
            dMesh = subj.discs.mesh(d);
    
            V = dMesh.alignedProperties.Points; % aligned points
            F = dMesh.alignedProperties.Faces; % faces aligned points
            
            disc.vertices = V;
            disc.faces    = F;
    
            % Geometric limits:
            bbox = [min(V,[],1); max(V,[],1)]'; % (3x2) bounding box of geometry
    
            % Slice locations along {x,y,z} axes:
            sx = linspace(bbox(1,1), bbox(1,2), numSlices);
            sy = linspace(bbox(2,1), bbox(2,2), numSlices);
            sz = linspace(bbox(3,1), bbox(3,2), numSlices);
    
            % Defining sets of three anatomical planes:
            [Px, Py, Pz] = makeAllPlanes(sx, sy, sz, bbox);
    
            % Looping through slices for all three anatomical planes:
            for k = 1:numSlices
                % --- Slice mesh with each plane ---
                ignorance = 0.1; % refers to how much of the inferior and superior slices will be ignored
                slices = sliceAllAxes(disc, Px(k), Py(k), Pz(k), k/numSlices, ignorance);
    
                % --- Measurement outputs ---
                measures.csa.X(k) = slices.X.area;
                measures.csa.Y(k) = slices.Y.area;
                measures.csa.Z(k) = slices.Z.area;

                measures.widths.X(k,:) = slices.X.widths.w;
                measures.widths.Y(k,:) = slices.Y.widths.w;
                measures.widths.Z(k,:) = slices.Z.widths.w;

                % Erase the previous line using the stored length
                fprintf(repmat('\b', 1, nbytes));
                nbytes = fprintf(['Slicer measurements progress: ' ...
                        'Subject %d/%d | Disc %d/%d | %5.1f%% progress | %5.1f%% complete \r'], ...
                        i, n, d, subj.discs.numLevels, pct, k/numSlices * 100);
            
                % --- Live visualization ---
                monitorDiscSlices = cfg.plot.monitorDiscSlices; % getting config settings
                
                % Monitoring disc slicer measurement process:
                if monitorDiscSlices
                    % reusing figure for slicing process:
                    if ~exist('slicesfig','var') || ~ishandle(slicesfig)
                        slicesfig = plotSliceMonitor(dMesh, slices, k, cfg, measures, figure);
                    else
                        slicesfig = plotSliceMonitor(dMesh, slices, k, cfg, measures, slicesfig);
                    end
                end
            end
    
            % Appending 'measures' to 'measurements' struct:
            measurements(d) = measures;
        end
    
        clc; % clearing progress bar after each subject has been processed
    
        % Appending 'measurements' to 'subjectData' struct:
        subjectData.subject(i).discs.measurements = measurements;
    end
end
fprintf('Slicer measurements done in %.2f seconds (%.2f minutes).\n', toc, toc/60);

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

