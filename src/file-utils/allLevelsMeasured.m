function tf = allLevelsMeasured(subj, savedConfig, cfg)

    tf = true;

    % Sanity checking saved config struc array:
    if ~isfield(savedConfig.measurements, 'APrl') || ~isfield(savedConfig.measurements, 'APru')
        tf = false;
        return
    end

    if ~isfield(savedConfig.measurements, 'LATrl') || ~isfield(savedConfig.measurements, 'LATru')
        tf = false;
        return
    end

    % Measurement frequencies and ignorances of current config settings:
    currNumSlices = cfg.measurements.numSlices;
    currHeightResolution = cfg.measurements.heightResolution;

    currSlicerIgnorance = cfg.measurements.slicerIgnorance;
    currHeightIgnorance = cfg.measurements.heightIgnorance;

    currAPrl = cfg.measurements.APrl;
    currAPru = cfg.measurements.APru;

    currLATrl = cfg.measurements.LATrl;
    currLATru = cfg.measurements.LATru;

    % Measurement frequencies and ignorances of saved config settings:
    savNumSlices = savedConfig.measurements.numSlices;
    savHeightResolution = savedConfig.measurements.heightResolution;

    savSlicerIgnorance = savedConfig.measurements.slicerIgnorance;
    savHeightIgnorance = savedConfig.measurements.heightIgnorance;

    savAPrl = savedConfig.measurements.APrl;
    savAPru = savedConfig.measurements.APru;

    savLATrl = savedConfig.measurements.LATrl;
    savLATru = savedConfig.measurements.LATru;
    
    % Checking that the current config settings are the same as the 
    % savaed measurement settings:
    if (currNumSlices ~= savNumSlices) || ...
        (currHeightResolution ~= savHeightResolution) || ...
        (currSlicerIgnorance ~= savSlicerIgnorance) || ...
        (currHeightIgnorance ~= savHeightIgnorance) || ...
        (currAPrl ~= savAPrl) || ...
        (currAPru ~= savAPru) || ...
        (currLATrl ~= savLATrl) || ...
        (currLATru ~= savLATru)
        tf = false;
        return
    end

    % ---- Vertebrae ----
    if ~isfield(subj.vertebrae, 'measurements')
        tf = false;
        return
    end
    meas = subj.vertebrae.measurements;

    % Sanity checking measurement struc array:
    if isempty(meas) || ~isfield(meas, 'slicer') || ~isfield(meas, 'height') || ~isfield(meas, 'vol')
        tf = false;
        return
    end
    slices  = meas.slicer; % slicer measurements (csa, widths, slice)
    heights = meas.height; % height measurements (LAT, AP)
    vols    = meas.vol; % volume measurements

    % Checking if the measurements fields inside of 'meas' exist and have
    % complete measurements:
    for i = 1:subj.vertebrae.numLevels
        allFieldsExist = isfield(slices(i), 'csa') && isfield(slices(i), 'widths') && isfield(slices(i), 'slice') && ...
                            isfield(heights(i), 'LAT') && isfield(heights(i), 'AP') && isfield(heights(i), 'APr') && isfield(heights(i), 'LATr');
        
        % Slicer measurements are complete if not all {X,Y,Z} entries
        % in the 'csa', 'widths', and 'slice' data structures are zero, 
        % checking if there are *any* non-zero entries in the following 
        % slicer measurements:
        slicerMeasurementsComplete = ...
            (any(slices(i).csa.X ~= 0,'all') && any(slices(i).csa.Y ~= 0,'all') && any(slices(i).csa.Z ~= 0,'all')) && ...
            (any(slices(i).widths.X ~= 0,'all') && any(slices(i).widths.Y ~= 0,'all') && any(slices(i).widths.Z ~= 0,'all')) && ...
            (any(slices(i).slice.X ~= 0,'all') && any(slices(i).slice.Y ~= 0,'all') && any(slices(i).slice.Z ~= 0,'all'));
        
        % Height measurements are complete if not all entries in the 'LAT'
        % and 'AP' profile and coords data structures are zero, checking if
        % there are *any* non-zero entries in the following height 
        % measurements:
        heightMeasurementsComplete = ...
            (any(heights(i).LAT.profile ~= 0,'all') && any(heights(i).LAT.coords ~= 0,'all')) && ...
            (any(heights(i).AP.profile ~= 0,'all') && any(heights(i).AP.coords ~= 0,'all')) && ...
            (~isempty(heights(i).APr)) && (~isempty(heights(i).LATr));

        % Volume measurements are complete if not all entries in the 'vol'
        % field are zero, checking if there are *any* non-zero entries in 
        % the following volume measurements:
        volumeMeasurementsComplete = (any(vols(i) ~= 0,'all'));

        if ~allFieldsExist || ~slicerMeasurementsComplete || ~heightMeasurementsComplete || ~volumeMeasurementsComplete
            tf = false;
            return
        end
    end
    
    % ---- Discs ----
    if ~isfield(subj.discs, 'measurements')
        tf = false;
        return
    end
    meas = subj.discs.measurements;

    % Sanity checking measurement struc array:
    if isempty(meas) || ~isfield(meas, 'slicer') || ~isfield(meas, 'height') || ~isfield(meas, 'vol')
        tf = false;
        return
    end
    slices  = meas.slicer; % slicer measurements (csa, widths, slice)
    heights = meas.height; % height measurements (LAT, AP)
    vols    = meas.vol; % volume measurements

    % Checking if the measurements fields inside of 'meas' exist and have
    % complete measurements:
    for i = 1:subj.discs.numLevels
        allFieldsExist = isfield(slices(i), 'csa') && isfield(slices(i), 'widths') && isfield(slices(i), 'slice') && ...
                            isfield(heights(i), 'LAT') && isfield(heights(i), 'AP') && isfield(heights(i), 'APr') && isfield(heights(i), 'LATr');
        
        % Slicer measurements are complete if not all {X,Y,Z} entries
        % in the 'csa', 'widths', and 'slice' data structures are zero, 
        % checking if there are *any* non-zero entries in the following 
        % slicer measurements:
        slicerMeasurementsComplete = ...
            (any(slices(i).csa.X ~= 0,'all') && any(slices(i).csa.Y ~= 0,'all') && any(slices(i).csa.Z ~= 0,'all')) && ...
            (any(slices(i).widths.X ~= 0,'all') && any(slices(i).widths.Y ~= 0,'all') && any(slices(i).widths.Z ~= 0,'all')) && ...
            (any(slices(i).slice.X ~= 0,'all') && any(slices(i).slice.Y ~= 0,'all') && any(slices(i).slice.Z ~= 0,'all'));
        
        % Height measurements are complete if not all entries in the 'LAT'
        % and 'AP' profile and coords data structures are zero, checking if
        % there are *any* non-zero entries in the following height 
        % measurements:
        heightMeasurementsComplete = ...
            (any(heights(i).LAT.profile ~= 0,'all') && any(heights(i).LAT.coords ~= 0,'all')) && ...
            (any(heights(i).AP.profile ~= 0,'all') && any(heights(i).AP.coords ~= 0,'all')) && ...
            (~isempty(heights(i).APr)) && (~isempty(heights(i).LATr));
        
        % Volume measurements are complete if not all entries in the 'vol'
        % field are zero, checking if there are *any* non-zero entries in 
        % the following volume measurements:
        volumeMeasurementsComplete = (any(vols(i) ~= 0,'all'));

        if ~allFieldsExist || ~slicerMeasurementsComplete || ~heightMeasurementsComplete || ~volumeMeasurementsComplete
            tf = false;
            return
        end
    end
end

