function cfg = makeConfig()
% Creating a config builder function

    % -------------------------------
    % Disc construction parameters
    % -------------------------------
    cfg.disc.endplatePercentile = 15;        % top/bottom % of vertebra
    cfg.disc.loftMethod         = "linear"; % "linear" | "pca"
    cfg.disc.numLoftSlices      = 25;

    % -------------------------------
    % Plotting (if 'false', plots will be skipped)
    % -------------------------------
    cfg.plot.showGeometryMetadata = true;
    cfg.plot.showDiscEndplatePoints = true;

end

