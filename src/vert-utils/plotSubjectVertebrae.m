function plotSubjectVertebrae(subject)
% Plotting all vertebra meshes for a single subject

    figure; hold on; axis equal;
    title("Subject " + subject.vertebrae.subjName, "Interpreter","none");

    meshes = subject.vertebrae.mesh;
    cmap = lines(numel(meshes));

    for k = 1:numel(meshes)
        TR = meshes(k).TR;

        trisurf(TR.ConnectivityList, ...
                TR.Points(:,1), ...
                TR.Points(:,2), ...
                TR.Points(:,3), ...
                'FaceColor', cmap(k,:), ...
                'EdgeColor','none', ...
                'FaceAlpha',0.9);

        c = meshes(k).centroid;
        plot3(c(1), c(2), c(3), 'k.', 'MarkerSize', 15);
        text(c(1), c(2), c(3), meshes(k).levelName);
    end

    lighting gouraud;
    camlight headlight;
    view(3);
end

