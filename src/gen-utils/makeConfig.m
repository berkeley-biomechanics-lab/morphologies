function cfg = makeConfig()
% Creating a config builder function

    % -------------------------------
    % Subject information
    % -------------------------------
    cfg.subjects.measuredLevels = "all"; % # of levels > 2!
    cfg.subjects.measuredSubjects = "all";

    % -------------------------------
    % Disc construction
    % -------------------------------
    cfg.disc.alreadyMade = true; % if 'true', then disc construction will be skipped altogether

    % Geometric tolerances used to isolate the endplate surface near the 
    % extremum of the signed-distance field:
    cfg.disc.alpha        = 0.15;    % percentage of vertebral height
    cfg.disc.minThickness = 0.5;     % units = mm
    cfg.disc.maxThickness = 3.5;     % units = mm

    % lofting parameters:
    cfg.disc.nRings         = 20; % number of layers through thickness
    cfg.disc.bulgeAmplitude = 2;   % mm

    % -------------------------------------------------
    % Plotting (if 'false', plots will be skipped)
    % -------------------------------------------------
    % NOTE: some of these figures are graphics intensive, so turning many
    % of them on will likely cause MATLAB to fail. It is recommended to use
    % these for maitenance only!
    cfg.plot.showGeometryMetadata = false;

    cfg.plot.monitorDiscEndplates = true; % if '.alreadyMade' = true, then '.monitorDiscEndplates' will be skipped
    cfg.plot.showDiscMetadata = false;

    cfg.plot.showGeometryAlignments = false;

    cfg.plot.monitorVertebraSlices = false; % if 'makeVertebraSlices' = false, this is skipped
    cfg.plot.monitorDiscSlices = true; % if 'makeDiscSlices' = false, this is skipped

    % -------------------------------
    % Measurements
    % -------------------------------
    % Skipping measurements or not (mainly for maitenance):
    cfg.measurements.makeVertebraSlices = false;
    cfg.measurements.makeDiscSlices = true;

    % Slicer measurements are generally poorly calculated around the
    % boundaries of the geometries, so the inferior and superior width
    % measurements will be set to 0, given by the following tolerance:
    cfg.measurements.slicerIgnorance = 0.2; % 0 <= slicerIgnorance < 0.5

    % Measurement frequencies:
    cfg.measurements.numSlices = 50;

    % -------------------------------
    % Overwriting
    % -------------------------------
    % The user must also specify whether or not they wish to overwrite the
    % measurement process with the boolean variable 'measures'. This 
    % means if the measurements for a particular level have already been made,
    % processed, and written and 'measures' = false, then this level 
    % will be skipped.
    %
    % The measurement pipeline also includes an automated disc construction
    % process that models the IVD as the empty space in between the inferior
    % and superior vertebrae. These discs geometry will be created and exported
    % into stl files onto 'discPath'. If 'exports' = false, then disc 
    % levels that have already been exported will be skipped.
    cfg.overwrite.measures = true;
    cfg.overwrite.discExports = false; % if '.alreadyMade' = true, then '.discExports' will be skipped
end

