function plotDiscs(subject)
% Visualizing subject disc properties

    figure;
    sgtitle("Subject " + subject.name + " Visualization");

    ax1 = subplot(3,7,[1 17]); ax1.SortMethod = 'childorder';
    hold on; axis equal;
    title("Discal body meshes","Interpreter","none");
    xlabel('X'); ylabel('Y'); zlabel('Z')

    lighting gouraud;
    camlight headlight;
    view(3);

    meshes = subject.discs.mesh;
    cmap = lines(numel(meshes));

    for k = 1:numel(meshes)
        TR = meshes(k).TR;

        % -------------------------------------------------
        % Plot discal meshes
        % -------------------------------------------------
        trisurf(TR, 'FaceColor', cmap(k,:), 'EdgeColor','none', 'FaceAlpha',0.9);
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

    ax = subplot(3,7,[4 20]);
    hold on; axis equal;
    title("Mid-sagittal cross sections","Interpreter","none");
    xlabel('Y'); ylabel('Z');

    % -------------------------------------------------
    % Plot mid-sagittal contours
    % -------------------------------------------------
    plotSubjectMidSagittalContours(subject, ax);

    % -------------------------------------------------
    % Evaluate centerline
    % -------------------------------------------------
    N = 200;
    tFine = linspace(0,1,N);
    x = ppval(subject.centerline.ppX, tFine);
    y = ppval(subject.centerline.ppY, tFine);
    z = ppval(subject.centerline.ppZ, tFine);

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

