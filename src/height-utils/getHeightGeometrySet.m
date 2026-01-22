function [heights, job] = getHeightGeometrySet(meshArray, cfg, job)

    numLevels = numel(meshArray);

    % Preallocate output
    heights = repmat(struct('LAT', struct('grid',[],'profile',[],'coords',[]), ...
                                'AP', struct('grid',[],'profile',[],'coords',[]), ...
                                'centroid', struct('xy',[],'idx',[]), ...
                                'map2D', [], 'APr', [], 'LATr', []), numLevels, 1);

    for lvl = 1:numLevels
        job.levelIdx = lvl; job.count = job.count + 1;
        heights(lvl) = computeHeightMap(meshArray(lvl), cfg, job);
    end
end

