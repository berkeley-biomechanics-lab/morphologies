function plotHeightMap(height, mesh, fig)
% Visualize 2D height distribution

    set(0, 'CurrentFigure', fig); clf; 
    sgtitle("Subject " + mesh.subjName + ", " + mesh.levelName + " Visualization");

    subplot(3,3,[1 5]); hold on;
    H = height.map2D;
    LAT = height.LAT.grid;
    AP  = height.AP.grid;
    
    hImg = pcolor(LAT, AP, H, EdgeColor="none");

    % --- Make NaNs transparent ---
    set(hImg, 'AlphaData', ~isnan(H));

    % --- Labels ---
    xlabel('Lateral (X)'); ylabel('Anterior–Posterior (Y)');
    title('2D Height Map with AP / Lateral Profiles');

    colormap(parula); % or turbo, viridis, hot, etc.
    cb = colorbar;
    cb.Label.String = 'Height (mm)';

    % --- Overlay centroid ---
    cx = height.centroid.xy(1);
    cy = height.centroid.xy(2);

    plot(cx, cy, 'k*', ...
        'MarkerFaceColor','w', ...
        'MarkerSize',8, ...
        'LineWidth',1.5);

    % --- Overlay AP / LAT lines ---
    xlim = [min(height.LAT.coords) max(height.LAT.coords)];
    ylim = [min(height.AP.coords) max(height.AP.coords)];

    plot([cx cx], ylim, 'k:', 'LineWidth',1.5); % AP
    plot(xlim, [cy cy], 'k:', 'LineWidth',1.5); % LAT

    subplot(3,3,[3 6]);
    plot(height.AP.profile, height.AP.coords,'k','LineWidth',1.5)
    xlabel('Height (mm)'); ylabel('Anterior–Posterior (Y)');
    title('AP Height Profile');

    subplot(3,3,[7 8]);
    plot(height.LAT.coords, height.LAT.profile,'k','LineWidth',1.5)
    xlabel('Lateral (X)'); ylabel('Height (mm)');
    title('Lat Height Profile');

    subplot(3,3,9);
    surf(height.LAT.grid, height.AP.grid, height.map2D, EdgeColor="none")
    xlabel('Lateral (X)'); ylabel('Anterior–Posterior (Y)'); zlabel('Height (mm)');
    title('3D Height Profile'); view(3);

    drawnow;
end

