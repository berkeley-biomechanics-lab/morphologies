function cfg = makeConfig(projectPath)
% Creating a config builder function that determines the measurement
% procedures of the pipeline. If any of the following high level parameters
% are changed according to the previously defined settings in the saved
% files at 'data\raw', then the measurements will be rewritten:
%           1.) cfg.measurements.numSlices
%           2.) cfg.measurements.heightResolution
%           3.) cfg.measurements.slicerIgnorance
%           4.) cfg.measurements.slicerIgnorance

    % -------------------------------
    % Path information
    % -------------------------------
    cfg.paths.data = fullfile(projectPath, 'data');
    cfg.paths.rawMeasurements = fullfile(cfg.paths.data, 'raw');
    cfg.paths.sumMeasurements = fullfile(cfg.paths.data, 'summary');


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

    cfg.plot.monitorDiscEndplates = false; % if '.alreadyMade' = true, then '.monitorDiscEndplates' will be skipped
    cfg.plot.showDiscMetadata = false;

    cfg.plot.showGeometryAlignments = false;

    cfg.plot.monitorVertebraSlices = false; % if 'makeVertebraSlices' = false, this is skipped
    cfg.plot.monitorDiscSlices = false; % if 'makeDiscSlices' = false, this is skipped

    cfg.plot.monitorHeightMaps = false;


    % -------------------------------
    % Measurements
    % -------------------------------
    % Skipping measurements or not (mainly for maitenance), defaults = 'true':
    cfg.measurements.makeVertebraSlices = true;
    cfg.measurements.makeDiscSlices = true;

    cfg.measurements.makeVertebraHeights = true;
    cfg.measurements.makeDiscHeights = true;

    cfg.measurements.makeVertebraVols = true;
    cfg.measurements.makeDiscVols = true;

    % Slicer measurements are generally poorly calculated around the
    % boundaries of the geometries, so the inferior and superior width
    % measurements will be set to 0, given by the following tolerance:
    cfg.measurements.slicerIgnorance = 0.1; % 0 <= slicerIgnorance < 0.5, <--- if changed, files will be rewritten
    cfg.measurements.heightIgnorance = 0.1; % 0 <= heightIgnorance < 0.5, <--- if changed, files will be rewritten

    % Measurement frequencies:
    cfg.measurements.numSlices        = 200; % <--- if changed, files will be rewritten
    cfg.measurements.heightResolution = 200; % <--- if changed, files will be rewritten


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
    cfg.overwrite.measures = false;
    cfg.overwrite.discExports = false; % if '.alreadyMade' = true, then '.discExports' will be skipped

    % -------------------------------
    % Data summary
    % -------------------------------
    cfg.summary.levelsVisualized = ["T1","L6"]; % endpoint spinal levels to be visualized (default = all ["T1" --> "L6"])
    cfg.summary.levelsExported = ["T1","L6"]; % endpoint spinal levels to be used for scalar analysis and exported for SPM analysis
end

