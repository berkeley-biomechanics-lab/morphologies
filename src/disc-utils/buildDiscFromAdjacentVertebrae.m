function discMesh = buildDiscFromAdjacentVertebrae(supVertMesh, infVertMesh, cfg)
% Constructs an intervertebral disc volume between two adjacent vertebrae.
%
% INPUTS:
%   supMesh : struct (superior vertebra - relative to disc - mesh)
%   infMesh : struct (inferior vertebra - relative to disc - mesh)
%   cfg     : configuration struct
%
% OUTPUT:
%   discMesh : struct with triangulation + metadata

    % ------------------------------------------------------------
    % 0. Config
    % ------------------------------------------------------------
    pct      = cfg.disc.endplatePercentile;
    nSlices  = cfg.disc.numLoftSlices;
    method   = cfg.disc.loftMethod;
    
    % ------------------------------------------------------------
    % 1. Extract opposing endplates
    % ------------------------------------------------------------
    supDiscEnd = extractEndplate(supVertMesh, "inf", pct); % extracting 'inferior' side of 'superior' vertebra --> 'superior' disc endplate
    infDiscEnd = extractEndplate(infVertMesh, "sup", pct); % extracting 'superior' side of 'inferior' vertebra --> 'inferior' disc endplate
    
    %figure; hold on;
    %scatter3(supVertMesh.TR.Points(:,1), supVertMesh.TR.Points(:,2), supVertMesh.TR.Points(:,3), 'b')
    %scatter3(infVertMesh.TR.Points(:,1), infVertMesh.TR.Points(:,2), infVertMesh.TR.Points(:,3), 'r')
    %scatter3(supDiscEnd.Points(:,1), supDiscEnd.Points(:,2), supDiscEnd.Points(:,3), 'k')
    %scatter3(infDiscEnd.Points(:,1), infDiscEnd.Points(:,2), infDiscEnd.Points(:,3), 'b')

    % Safety check
    if isempty(supDiscEnd.Points) || isempty(infDiscEnd.Points)
        error("Endplate extraction failed for %s–%s.", ...
            supVertMesh.levelName, infVertMesh.levelName);
    end
    
    % ------------------------------------------------------------
    % 2. Align endplates in correspondence
    %    (PCA-based ordering → robust to curvature)
    % ------------------------------------------------------------
    supLoop = orderEndplateLoop(supDiscEnd.Points);
    infLoop = orderEndplateLoop(infDiscEnd.Points);
    
    % Resample to same number of points
    n = max(size(supLoop,1), size(infLoop,1));
    supLoop = resampleClosedCurve(supLoop, n);
    infLoop = resampleClosedCurve(infLoop, n);
    
    % ------------------------------------------------------------
    % 3. Loft between endplates
    % ------------------------------------------------------------
    switch method
        case "linear"
            V = loftLinear(supLoop, infLoop, nSlices);
    
        case "pca"
            V = loftPCA(supLoop, infLoop, nSlices);
    
        otherwise
            error("Unknown loft method: %s", method);
    end
    
    % ------------------------------------------------------------
    % 4. Surface triangulation
    % ------------------------------------------------------------
    F = triangulateLoft(n, nSlices);
    
    TR = triangulation(F, V);
    
    % ------------------------------------------------------------
    % 5. Populate output struct
    % ------------------------------------------------------------
    discMesh = struct();
    
    discMesh.levelName   = supVertMesh.levelName + "-" + infVertMesh.levelName;
    discMesh.supLevel    = supVertMesh.levelName;
    discMesh.infLevel    = infVertMesh.levelName;
    
    discMesh.TR          = TR;
    discMesh.numVertices = size(V,1);
    discMesh.numFaces    = size(F,1);
    
    discMesh.centroid    = mean(V, 1);
    discMesh.thickness   = mean(vecnorm(supLoop - infLoop, 2, 2));

end

