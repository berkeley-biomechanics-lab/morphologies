function fig = plotSliceMonitor(object, slices, k, cfg, measurements, fig)
% Visualizing slicing properties of 'object' which refers to a vertebra or 
% disc '.mesh' field.

    % Getting object properties:
    subjName  = object.subjName;
    levelName = object.levelName;
    TR        = object.alignedProperties.TR; % getting aligned TR field

    % Getting slices properties:
    slicerTitle = "(" + string(k) + "/" + string(cfg.measurements.numSlices) + ")";

    set(0, 'CurrentFigure', fig); clf;
    sgtitle("Subject " + subjName + " Visualization");

    % -------------------------------------------------
    % Slice configuration table
    % -------------------------------------------------
    sliceCfg = struct( ...
        'name',   {'Z','Y','X'}, ...
        'label',  {'Sup-inf (Z)','Ant-post (Y)','Left-right (X)'}, ...
        'slice',  {slices.Z, slices.Y, slices.X}, ...
        'csa',    {measurements.csa.Z, measurements.csa.Y, measurements.csa.X}, ...
        'widths', {measurements.widths.X, measurements.widths.Y, measurements.widths.Z}, ...
        'ax3D',   {[1 21],[4 24],[7 27]}, ...
        'ax2D',   {28,31,34}, ...
        'axCSA',  {[29 30],[32 33],[35 36]} ...
    );

    % -------------------------------------------------
    % Loop over slice directions
    % -------------------------------------------------
    for i = 1:numel(sliceCfg)

        cfg_i = sliceCfg(i);

        % -------- 3D mesh + slice --------
        ax = subplot(4,9,cfg_i.ax3D);
        ax.SortMethod = 'childorder';
        hold on; view(3);

        title(cfg_i.label + " slicing for level " + levelName, ...
              "Interpreter","none");
        xlabel('X'); ylabel('Y'); zlabel('Z');

        trisurf(TR, ...
            'FaceColor',[0.7 0.7 0.7], ...
            'EdgeColor','none', ...
            'FaceAlpha',0.3);

        plotSliceCurves(cfg_i.slice);

        lighting gouraud
        camlight headlight
        material dull

        % -------- 2D polyshape --------
        subplot(4,9,cfg_i.ax2D); hold on;
        title("2D slice " + slicerTitle);
        plot(cfg_i.slice.poly, 'FaceColor',[0.7 0.7 0.7]);

        for j = 1:2
            % Only plots widths if they're are both non-zero:
            if ~any(cfg_i.slice.widths.w == 0)
                pjx1 = cfg_i.slice.widths.endpoints{j}(:,1); % coordinates in the x1 direction
                pjx2 = cfg_i.slice.widths.endpoints{j}(:,2); % coordinates in the x2 direction
    
                line(pjx1,pjx2,'Color','k','LineStyle','--');
                scatter(pjx1, pjx2, 'ko');
            end
        end

        % Plotting centroid (if widths exist):
        if ~any(cfg_i.slice.widths.w == 0)
            [Cx, Cy] = centroid(cfg_i.slice.poly); scatter(Cx, Cy, 'k*');
        end

        % -------- Measurement history --------
        subplot(4,9,cfg_i.axCSA); hold on;
        title("Measurements (units: mm)");
        yyaxis left; ax = gca; ax.YColor = 'k'; % activating the left y-axis
        plot(1:k, cfg_i.csa(1:k), '-k.'); ylim([0, inf]); % Autoscale ymax, set ymin to 0
        
        yyaxis right; ax = gca; ax.YColor = 'k'; % activating the right y-axis
        plot(1:k, cfg_i.widths(1:k,1), '-b.');
        plot(1:k, cfg_i.widths(1:k,2), '-r.');
        ylim([0, inf]); % Autoscale ymax, set ymin to 0

        xlabel("Slice index");
        legend('csa','w_1','w_2','Location','southeast');
    end

    drawnow;
end

