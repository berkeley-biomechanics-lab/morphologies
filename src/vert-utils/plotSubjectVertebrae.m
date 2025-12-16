function plotSubjectVertebrae(subject)
% Plotting all vertebra meshes for a single subject

    figure;
    sgtitle("Subject " + subject.vertebrae.subjName + " Visualization");
    ax1 = subplot(3,8,[1 19]); ax1.SortMethod = 'childorder';
    hold on; axis equal;
    title("Vertebral body meshes","Interpreter","none");
    xlabel('X'); ylabel('Y'); zlabel('Z')

    lighting gouraud;
    camlight headlight;
    view(3);

    C = subject.centerline.CVert;
    T = subject.centerline.TVert;

    meshes = subject.vertebrae.mesh;
    cmap = lines(numel(meshes));

    for k = 1:numel(meshes)
        TR = meshes(k).TR;

        % -------------------------------------------------
        % Plot vertebral meshes
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
    c = vertcat(meshes.centroid);
    n = vertcat(meshes.levelName);
    plot3(c(:,1), c(:,2), c(:,3), 'k.', 'MarkerSize', 15);
    text(c(:,1), c(:,2), c(:,3), n, ...
                            'FontSize', 14, ...
                            'FontWeight', 'bold');

    subplot(3,8,[4 22])
    hold on; axis equal; view(3);
    title("Vertebral centerline and tangents","Interpreter","none");
    xlabel('X'); ylabel('Y'); zlabel('Z')

    % ----------------------------------------------------------
    % Plot centerline tangents (stored collectively in C and T)
    % ----------------------------------------------------------
    scale = 0.3;
    quiver3( ...
        C(:,1), C(:,2), C(:,3), ...
        T(:,1), T(:,2), T(:,3), ...
            scale,'Color',[0.5 0 0], ...
            'LineWidth',2, ...
            'MaxHeadSize',0.5);

    % -------------------------------------------------
    % Plot centroids
    % -------------------------------------------------  
    plot3(c(:,1), c(:,2), c(:,3), 'k.', 'MarkerSize', 15);
    text(c(:,1), c(:,2), c(:,3), n, ...
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
    subplot(3,8,[7 8])
    hold on; axis equal;
    title("Sagittal centerline projection (YZ)","Interpreter","none");
    xlabel('Y'); ylabel('Z');
    plot(y, z, 'r-', 'LineWidth',3)

    subplot(3,8,[15 16])
    hold on; axis equal;
    title("Coronal centerline projection (XZ)","Interpreter","none");
    xlabel('X'); ylabel('Z');
    plot(x, z, 'r-', 'LineWidth',3)

    subplot(3,8,[23 24])
    hold on; axis equal;
    title("Transverse centerline projection (XY)","Interpreter","none");
    xlabel('X'); ylabel('Y');
    plot(x, y, 'r-', 'LineWidth',3)
end

