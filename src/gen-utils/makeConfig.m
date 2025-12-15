function cfg = makeConfig()
% Creating a config builder function

    % -------------------------------
    % Disc construction parameters
    % -------------------------------
    cfg.disc.endplatePercentile = 15;        % top/bottom % of vertebra
    cfg.disc.loftMethod         = "linear"; % "linear" | "pca"
    cfg.disc.numLoftSlices      = 25;

    % -------------------------------
    % Plotting
    % -------------------------------
    cfg.plot.showSubjectVertebrae = false; % if 'false', vertebra mesh plots will be skipped
    cfg.plot.showDiscEndplatePoints = true;

end

