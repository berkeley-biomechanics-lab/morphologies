function plotRawHeightRs(T, varargin)
% Plots raw height ratio measurements across spinal levels.
% One line per subject, colored by group.
%
% INPUT
% -----
% T : table returned by buildMeasurementTables() for height ratios
%
% OPTIONAL NAME-VALUE PAIRS
% -------------------------
% 'Structure' : 'vertebra' | 'disc' | 'all' (default)
% 'PlotType'  : 'line' (default) | 'scatter'
% 'Alpha'     : transparency (default)
%
% Control subjects  -> red
% Kyphotic subjects -> blue
%
% EXAMPLE
% -------
% plotRawHeightRs(Theightrs,'Structure','vertebra')
% plotRawHeightRs(Theightrs,'Structure','disc','PlotType','scatter')

    % -----------------------------
    % Parse inputs
    % -----------------------------
    p = inputParser;
    addRequired(p,'T',@(x)istable(x));

    addParameter(p,'Structure','all',@(x)ischar(x)||isstring(x));
    addParameter(p,'PlotType','line',@(x)ischar(x)||isstring(x));
    addParameter(p,'Alpha',0.3,@(x)isnumeric(x)&&isscalar(x));
    addParameter(p,'Levels',[],@(x)isstring(x)||iscellstr(x));

    parse(p,T,varargin{:});
    opt = p.Results;

    % ----------------------------------
    % Optional level filtering
    % ----------------------------------
    if ~isempty(opt.Levels)
        T = filterTableByLevels(T, opt.Levels);
    end

    % ----------------------------------
    % Filter by structure
    % ----------------------------------
    if opt.Structure ~= "all"
        T = T(T.Structure == opt.Structure,:);
    end
    
    % Remove unused categories
    T.LevelName = removecats(T.LevelName);

    % ----------------------------------
    % Build structure-specific x-axis
    % ----------------------------------
    levelCats = categories(T.LevelName);
    ord = sortLevelNames(levelCats);
    
    T.LevelName = categorical( ...
        T.LevelName, ...
        levelCats(ord), ...
        'Ordinal', true);

    % -----------------------------
    % Color convention
    % -----------------------------
    col.control  = [0.85 0.1 0.1];
    col.kyphotic = [0.1 0.3 0.8];

    % -----------------------------
    % Figure setup
    % -----------------------------
    figure('Color','w','Name','Raw Height Ratios');

    sgtitle(sprintf('Raw Height Ratios | Structure: %s | Plot: %s', ...
        opt.Structure, opt.PlotType), ...
        'FontWeight','bold');

    directions = {'LAT','AP'};

    % -----------------------------
    % Loop over directions
    % -----------------------------
    for d = 1:2
        dirName = directions{d};
        subplot(1,2,d); hold on;

        % --- Filter table by direction ---
        T_dir = T(T.Axis == dirName,:);
        if isempty(T_dir)
            title(dirName + " (no data)");
            continue;
        end

        % Dummy legend handles
        hControl  = plot(nan,nan,'Color',col.control,'LineWidth',1.5);
        hKyphotic = plot(nan,nan,'Color',col.kyphotic,'LineWidth',1.5);

        % -----------------------------
        % Group by subject
        % -----------------------------
        [G, ~] = findgroups(T_dir.SubjectID);
    
        for k = 1:max(G)
    
            idx = (G == k);
            Tk = T_dir(idx,:);
    
            if Tk.isKyphotic(1)
                color = col.kyphotic;
            else
                color = col.control;
            end
    
            x = double(Tk.LevelName);   % ordinal
            y = Tk.HeightR;
    
            switch lower(opt.PlotType)
                case 'line'
                    plot(x, y, ...
                        'Color',[color opt.Alpha], ...
                        'LineWidth',0.8);
    
                case 'scatter'
                    scatter(x, y, 18, color, ...
                        'filled', ...
                        'MarkerFaceAlpha',opt.Alpha);
            end
        end
    
        % -----------------------------
        % Axes & labels
        % -----------------------------
        set(gca,'XTick',1:numel(categories(T.LevelName)), ...
                'XTickLabel',categories(T.LevelName));
    
        xlabel('Spinal level');
        ylabel('Height Ratio (mm/mm)');

        title(sprintf( ...
            '%s direction | %s | %s', ...
            dirName, 'Height Ratio', opt.Structure));
    
        legend([hControl hKyphotic], ...
            {'Control','Kyphotic'}, ...
            'Location','best');
    
        box on;
        grid off;
    end
end

