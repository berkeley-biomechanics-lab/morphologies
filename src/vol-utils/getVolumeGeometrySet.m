function [vols, jobInfo] = getVolumeGeometrySet(geometry, jobInfo)
% geometry : subj.vertebrae OR subj.discs

    numLevels = geometry.numLevels;
    
    % Preallocate output
    vols = zeros(1, numLevels);
    
    for lvl = 1:numLevels
        jobInfo.count = jobInfo.count + 1;

        % Getting slicer information:
        slicePos = geometry.measurements.slicer(lvl).slice.Z;
        CSA      = geometry.measurements.slicer(lvl).csa.Z;

        % Updating volume storage:
        vols(lvl) = getVolume(slicePos, CSA, geometry.levelNames(lvl), jobInfo);
    end
end

