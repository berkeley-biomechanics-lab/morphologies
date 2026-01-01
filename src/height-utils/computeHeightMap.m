function height = computeHeightMap(mesh, cfg, job)
% Vectorized height-map computation using batched rays

    monitor = cfg.plot.monitorHeightMaps;
    ignorance = cfg.measurements.heightIgnorance;
    res = cfg.measurements.heightResolution;

    V = mesh.alignedProperties.Points;
    F = mesh.alignedProperties.Faces;
    tri = preprocessTriangles(V, F);

    % ---- Grid definition ----
    nAP  = res; nLAT = res;

    xmin = min(V(:,1)); xmax = max(V(:,1));
    ymin = min(V(:,2)); ymax = max(V(:,2));
    zmin = min(V(:,3));

    LATcoords = linspace(xmin, xmax, nLAT);
    APcoords  = linspace(ymin, ymax, nAP);

    % ---- Vectorized ray origins ----
    [LAT, AP] = ndgrid(LATcoords, APcoords);

    nRays = numel(LAT);

    rayOrigins = [ ...
        LAT(:), ...
        AP(:), ...
        repmat(zmin - 1e-3, nRays, 1) ...
    ];

    % ---- Batched ray intersections ----
    heights = nan(nRays, 1);

    % Use PARFOR here if desired
    parfor r = 1:nRays
        zHits = intersectRayMesh(rayOrigins(r,:), tri);
        if numel(zHits) >= 2
            heights(r) = max(zHits) - min(zHits);
        end
    end

    % ---- Reshape back to grid ----
    heightMap = reshape(heights, nLAT, nAP);
    heightMap = heightMap'; LAT = LAT'; AP = AP'; % reorienting axes

    % Characterizing NaNs in 2D position fields:
    validMask = isnan(heightMap);
    AP(validMask) = NaN; LAT(validMask) = NaN;
    
    height.LAT.grid = LAT;
    height.AP.grid = AP;

    % --- Compute centroid in 2D plane ---
    iCentLAT = ceil(nLAT/2) + 1; iCentAP  = ceil(nAP/2) + 1;
    cx = LAT(iCentLAT, iCentAP);
    cy = AP(iCentLAT, iCentAP);
    
    height.centroid.xy = [cx, cy];
    height.centroid.idx = [iCentLAT, iCentAP];

    % ---- Package output ----
    height.map2D = heightMap;

    % ---- 1D height profiles (centerline sampling) ----
    iLAT = iCentLAT; iAP  = iCentAP;
    height.LAT.profile = heightMap(iCentAP,:);
    height.AP.profile  = heightMap(:,iCentLAT)';

    height.LAT.coords = LAT(iAP,:);
    height.AP.coords  = AP(:,iLAT)';

    % Applying 'ignorance' data processing
    krs = (1:res)/res;
    ignoranceMask = krs <= ignorance | krs >= (1-ignorance);
            
    height.LAT.coords(ignoranceMask) = NaN;
    height.LAT.profile(ignoranceMask) = NaN;

    height.AP.coords(ignoranceMask) = NaN;
    height.AP.profile(ignoranceMask) = NaN;

    if monitor
        plotHeightMap(height, mesh, gcf)
    end

    % ---- Progress update ----
    heightProgressUpdate(job, mesh.levelName)
end

