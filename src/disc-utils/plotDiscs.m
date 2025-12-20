function plotDiscs(subject)
% Visualizing subject disc properties

    figure;
    sgtitle("Subject " + subject.discs.subjName + " Visualization");

    ax1 = subplot(3,7,[1 17]); ax1.SortMethod = 'childorder';
    hold on; axis equal;
    title("Discal body meshes","Interpreter","none");
    xlabel('X'); ylabel('Y'); zlabel('Z')

    lighting gouraud;
    camlight headlight;
    view(3);

    CDisc = subject.centerline.discs.C;
    TDisc = subject.centerline.discs.T;

    meshes = subject.discs.mesh;
    cmap = lines(numel(meshes));

    for k = 1:numel(meshes)
        TR = meshes(k).TR;

        % -------------------------------------------------
        % Plot discal meshes
        % -------------------------------------------------
        trisurf(TR.ConnectivityList, ...
                TR.Points(:,1), ...
                TR.Points(:,2), ...
                TR.Points(:,3), ...
                'FaceColor', cmap(k,:), ...
                'EdgeColor','none', ...
                'FaceAlpha',0.9);
    end
    % -------------------------------------------------
    % Plot centroids
    % -------------------------------------------------  
    cVert = subject.centerline.discs.C;
    nVert = subject.centerline.discs.levelNames;
    plot3(cVert(:,1), cVert(:,2), cVert(:,3), 'k.', 'MarkerSize', 15);
    text(cVert(:,1), cVert(:,2), cVert(:,3), nVert, ...
                            'FontSize', 14, ...
                            'FontWeight', 'bold');

    subplot(3,7,[4 20])
    hold on; axis equal; view(3);
    title("Discal centerline and tangents","Interpreter","none");
    xlabel('X'); ylabel('Y'); zlabel('Z')

    % ----------------------------------------------------------
    % Plot vertebra centerline + tangents (stored collectively in C and T)
    % ----------------------------------------------------------
    scale = 0.3;
    quiver3( ...
        CDisc(:,1), CDisc(:,2), CDisc(:,3), ...
        TDisc(:,1), TDisc(:,2), TDisc(:,3), ...
            scale,'Color',[0.5 0 0], ...
            'LineWidth',2, ...
            'MaxHeadSize',0.5);

    % -------------------------------------------------
    % Plot centroids
    % -------------------------------------------------  
    plot3(cVert(:,1), cVert(:,2), cVert(:,3), 'k.', 'MarkerSize', 15);
    text(cVert(:,1), cVert(:,2), cVert(:,3), nVert, ...
                            'FontSize', 14, ...
                            'FontWeight', 'bold');

    % -------------------------------------------------
    % Evaluate and plot centerline
    % -------------------------------------------------
    N = 200;
    tFine = linspace(0,1,N);
    x = ppval(subject.centerline.ppX, tFine);
    y = ppval(subject.centerline.ppY, tFine);
    z = ppval(subject.centerline.ppZ, tFine);

    plot3(x, y, z, 'r-', 'LineWidth',3)
    legend({'tangents','centroids', 'centerline'},'Location','best')

    % -------------------------------------------------
    % Plot 2D centerline projections
    % -------------------------------------------------
    subplot(3,7,7)
    hold on; axis equal;
    title("Sagittal centerline projection (YZ)","Interpreter","none");
    xlabel('Y'); ylabel('Z');
    plot(y, z, 'r-', 'LineWidth',3)

    subplot(3,7,14)
    hold on; axis equal;
    title("Frontal centerline projection (XZ)","Interpreter","none");
    xlabel('X'); ylabel('Z');
    plot(x, z, 'r-', 'LineWidth',3)

    subplot(3,7,21)
    hold on; axis equal;
    title("Transverse centerline projection (XY)","Interpreter","none");
    xlabel('X'); ylabel('Y');
    plot(x, y, 'r-', 'LineWidth',3)
end

