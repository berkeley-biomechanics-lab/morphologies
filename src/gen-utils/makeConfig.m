function cfg = makeConfig()
% Creating a config builder function

    % -------------------------------
    % Subject information
    % -------------------------------
    cfg.subjects.measuredLevels = "all";
    cfg.subjects.measuredSubjects = "all";

    % -------------------------------
    % Disc construction parameters
    % -------------------------------
    cfg.disc.alreadyMade = true; % if 'true', then disc construction will be skipped altogether

    % geometric tolerances used to isolate the endplate surface near the 
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
    cfg.plot.showGeometryMetadata = false;

    cfg.plot.monitorDiscEndplates = true; % if '.alreadyMade' = true, then '.monitorDiscEndplates' will be skipped
    cfg.plot.showDiscMetadata = false;

    cfg.plot.showGeometryAlignments = false;

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

