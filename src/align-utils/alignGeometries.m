%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: alignGeometries.m
% Author: Yousuf Abubakr
% Project: Morphologies
% Last Updated: 12-23-2025
%
% Description: centering and rotating the geometric bodies into a common 
% Cartesian coordinate frame defined by the standard orthonormal basis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; % clearing command window

% Getting workspace variables at the start of the new script:
varsbefore = who;

%% COMPUTING CENTERING TRANSLATION VECTOR
% Defining the translation vector associated with the rigid body (RB)
% transformation associated with each geometry's soon-to-be aligned
% mesh geometry.

n = subjectData.numSubjects; % number of subjects

% Looping through each subject's geometries and finding the appropriate 
% centering translation vector:
for i = 1:n
% Choosing the already determined '.centerline.C' points on every subject's
% centerline and assigning these points to each RB translation

    subj = subjectData.subject(i); % ith subject
    CL   = subj.centerline; % ith subject's centerline

    % Initialize alignment struct
    subjectData.subject(i).alignment.vertebrae = struct([]);
    subjectData.subject(i).alignment.discs     = struct([]);

    % ================= VERTEBRAE =================
    for v = 1:subj.vertebrae.numLevels

        % --- Translation (centerline-based) ---
        t   = -CL.vertebrae.C(v,:);

        % --- Store alignment metadata ---
        subjectData.subject(i).alignment.vertebrae(v).translation = t;
    end

    % ================= DISCS =================
    for d = 1:subj.discs.numLevels

        % --- Translation (centerline-based) ---
        t   = -CL.discs.C(d,:);

        % --- Store alignment metadata ---
        subjectData.subject(i).alignment.discs(d).translation = t;
    end
end

%% COMPUTING ALIGNMENT ROTATION MATRIX
% Defining the rotation matrix associated with the rigid body (RB)
% transformation associated with each geometry's soon-to-be aligned
% mesh geometry.

% Looping through each subject's geometries and finding the appropriate 
% alignment rotation matrix:
for i = 1:n
% Choosing the already determined '.centerline.T' tangent vectors on every 
% subject's centerline, defining a unique local coordinate system, and
% construction an associated (3x3) rotation matrix

    subj = subjectData.subject(i); % ith subject
    CL   = subj.centerline; % ith subject's centerline

    % ================= VERTEBRAE =================
    for v = 1:subj.vertebrae.numLevels

        % --- Rotation (centerline-based) ---
        T = CL.vertebrae.T(v,:); % Get the tangent vector for the vertebrae
        R = rotationFromTangent(T); % Compute the rotation matrix from the tangent vector

        % --- Store alignment metadata ---
        subjectData.subject(i).alignment.vertebrae(v).rotation = R;
    end

    % ================= DISCS =================
    for d = 1:subj.discs.numLevels

        % --- Rotation (centerline-based) ---
        T = CL.discs.T(d,:); % Get the tangent vector for the disc
        R = rotationFromTangent(T); % Compute the rotation matrix from the tangent vector

        % --- Store alignment metadata ---
        subjectData.subject(i).alignment.discs(d).rotation = R;
    end
end

%% TRANSFORMING GEOMETRIC BODIES
% Transforming each subject's geometries by applying the rotation matrix
% and translation vector to each body

% Transforming each subject's geometries:
for i = 1:n

    subj = subjectData.subject(i); % ith subject

    % ================= VERTEBRAE =================
    for v = 1:subj.vertebrae.numLevels

        % --- Original mesh ---
        TR  = subj.vertebrae.mesh(v).TR;
        V   = TR.Points;
        F   = TR.ConnectivityList;

        % --- Rigid-body transform ---
        t = subj.alignment.vertebrae(v).translation;   % 1×3
        R = subj.alignment.vertebrae(v).rotation;      % 3×3

        % Apply transform: translate → rotate
        V0 = V + t;                    % translate
        V1 = (R * V0')';               % rotate

        % --- Store aligned mesh ---
        subjectData.subject(i).vertebrae.mesh(v).alignedProperties = struct( ...
            'Points', V1, ...
            'Faces',  F, ...
            'TR',     triangulation(F, V1), ...
            'centroid', mean(V1, 1) ...
        );
    end

    % ================= DISCS =================
    for d = 1:subj.discs.numLevels

        % --- Original mesh ---
        TR  = subj.discs.mesh(d).TR;
        V   = TR.Points;
        F   = TR.ConnectivityList;

        % --- Rigid-body transform ---
        t = subj.alignment.discs(d).translation;   % 1×3
        R = subj.alignment.discs(d).rotation;      % 3×3

        % Apply transform: translate → rotate
        V0 = V + t;
        V1 = (R * V0')';

        % --- Store aligned mesh ---
        subjectData.subject(i).discs.mesh(d).alignedProperties = struct( ...
            'Points', V1, ...
            'Faces',  F, ...
            'TR',     triangulation(F, V1), ...
            'centroid', mean(V1, 1) ...
        );
    end
end

%% VISUALIZATION
% Plotting each subjects' vertebral bodies

showGeometryAlignments = cfg.plot.showGeometryAlignments; % getting config settings

% Skipping visualization if 'plotAlignments' = false:
if showGeometryAlignments
    % Visualizing alignment properties for all subjects:
    plotBeforeAfter(subjectData);
end

%% MATLAB CLEANUP
% Deleting extraneous subroutine variables:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {''};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})

