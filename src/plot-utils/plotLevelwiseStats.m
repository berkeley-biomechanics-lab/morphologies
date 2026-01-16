function plotLevelwiseStats(Tstats, structure, varargin)
% Visualize level-wise summary statistics
%
% Inputs
% ------
% Tstats    : output table from levelwiseTtests
% structure : 'vertebra' or 'disc'
%
% Optional name-value:
%   'UseQ'  : true (default) → significance from q-values
%   'Alpha' : significance threshold (default 0.05)
%   'Title' : custom title
%   'YLabel': y-axis label

    % -------------------------
    % Options
    % -------------------------
    p = inputParser;
    addParameter(p,'UseQ',true);
    addParameter(p,'Alpha',0.05);
    addParameter(p,'Title','');
    addParameter(p,'YLabel','Measurement');
    parse(p,varargin{:});
    opts = p.Results;

    % -------------------------
    % X-axis
    % -------------------------
    x = 1:height(Tstats);
    levels = Tstats.Level;

    % Significance mask
    if opts.UseQ
        sig = Tstats.qValue < opts.Alpha;
    else
        sig = Tstats.pValue < opts.Alpha;
    end

    % -------------------------
    % Figure
    % -------------------------
    figure('Color','w','Position',[100 100 1000 450]);

    hold on

    % --- Control ---
    errorbar(x, Tstats.MeanC, Tstats.StdC, ...
        'o-','Color',[0.8 0.2 0.2], ...
        'MarkerFaceColor',[0.8 0.2 0.2], ...
        'LineWidth',3);

    % --- Kyphotic ---
    errorbar(x, Tstats.MeanK, Tstats.StdK, ...
        'o-','Color',[0.2 0.2 0.8], ...
        'MarkerFaceColor',[0.2 0.2 0.8], ...
        'LineWidth',3);

    % --- Significance markers ---
    yMax = max([Tstats.MeanC + Tstats.StdC, ...
                Tstats.MeanK + Tstats.StdK], [], 2);
    yStar = yMax * 1.05;

    plot(x(sig), yStar(sig), 'k*', 'MarkerSize', 12)

    % -------------------------
    % Formatting
    % -------------------------
    set(gca,'XTick',x,'XTickLabel',levels)
    xtickangle(45)

    ylabel(opts.YLabel)
    xlabel('Spinal Level')
    ymin = 0;
    ylim([ymin Inf]);
    xlim([min(x) Inf]);

    % Get the current axes handle
    ax = gca;
    
    % Set the Exponent property to 0 to prevent scientific notation
    ax.YAxis.Exponent = 0;
    
    % Use ytickformat to ensure integer display without decimals
    ytickformat('%.0f');

    legend({'Control (mean ± SD)','Kyphotic (mean ± SD)','Significant'}, ...
           'Location','best')

    if isempty(opts.Title)
        title(sprintf('Level-wise statistics (%s)',structure))
    else
        title(opts.Title)
    end

    hold off
end

