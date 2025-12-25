function [supDiscEnd, infDiscEnd] = getEndplatesFromAdjacentVertebrae( ...
            supVertMesh, infVertMesh, centerline, cfg, discIdx)
% Constructs an intervertebral disc volume between two adjacent vertebrae.
%
% INPUTS:
%   supVertMesh : struct (superior vertebra - relative to disc - mesh)
%   infVertMesh : struct (inferior vertebra - relative to disc - mesh)
%   cfg         : configuration struct
%   centerline  : centerline struct
%   discIdx     : disc index
%
% OUTPUT:
%   discMesh : struct with triangulation + metadata

    % ---------------------------------------------------------
    % 1. Pull disc kinematics directly from centerline
    % ---------------------------------------------------------
    CDisc = centerline.discs.C(discIdx, :);
    TDisc = centerline.discs.T(discIdx, :);
    
    % ------------------------------------------------------------
    % 2. Extract opposing endplates
    % ------------------------------------------------------------
    % Extracting 'inferior' side of 'superior' vertebra --> 'superior' disc
    % endplate:
    supDiscEnd = extractEndplate(supVertMesh, CDisc, TDisc, "inf", cfg);

    % Extracting 'superior' side of 'inferior' vertebra --> 'inferior' disc
    % endplate:
    infDiscEnd = extractEndplate(infVertMesh, CDisc, TDisc, "sup", cfg);

    % ------------------------------------------------------------
    % 3. Choosing K-value (boundary curve resampling) adaptively
    % ------------------------------------------------------------
    Ps = supDiscEnd.Pb; % (ordered) boundary points of superior endplate
    Pi = infDiscEnd.Pb; % (ordered) boundary points of inferior endplate
    K = max(size(Ps,1), size(Pi,1));
    
    % ------------------------------------------------------------
    % 4. Resampling both boundary curves
    % ------------------------------------------------------------
    Ps = resampleClosedCurve(Ps, K);
    Pi = resampleClosedCurve(Pi, K);

    % ------------------------------------------------------------
    % 5. Aligning disc bonudaries
    % ------------------------------------------------------------
    [Pi, Ps] = alignDiscBoundaries(Pi, Ps);

    % ------------------------------------------------------------
    % 6. Reassigning endplate boundary curves
    % ------------------------------------------------------------
    supDiscEnd.Pb = Ps; % (ordered and resampled)
    infDiscEnd.Pb = Pi; % (ordered and resampled)

    % Safety check
    if isempty(supDiscEnd.TR.Points) || isempty(infDiscEnd.TR.Points)
        error("Endplate extraction failed for %s–%s.", ...
            supVertMesh.levelName, infVertMesh.levelName);
    end
end

