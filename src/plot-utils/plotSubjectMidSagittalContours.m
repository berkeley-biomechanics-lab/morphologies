function ax = plotSubjectMidSagittalContours(subject, ax)
% Plot mid-sagittal contours of vertebrae and discs into provided axes.
%
% Since all meshes are watertight, SurfaceIntersection returns a single
% clean closed loop per geometry. Each loop is chained into order and
% plotted with patch().

    hold(ax, 'on');

    nVert = subject.vertebrae.numLevels;
    nDisc = subject.discs.numLevels;

    vertColors = parula(nVert);
    discColors = autumn(nDisc) * 0.9;

    % -------------------------
    % Vertebrae contours
    % -------------------------
    V     = subject.vertebrae;
    Cvert = subject.centerline.vertebrae.C;

    for i = 1:nVert
        TR   = V.mesh(i).TR;
        xMid = Cvert(i,1);

        loops = extractMidSagittalContour(TR, xMid);
        if isempty(loops), continue; end

        % Use the longest loop (should be the only one for watertight mesh):
        loop = getLongestLoop(loops);
        if size(loop,1) < 3, continue; end

        patch(ax, loop(:,1), loop(:,2), vertColors(i,:), ...
              'FaceAlpha', 0.35, ...
              'EdgeColor', [0 0 0], ...
              'LineWidth', 0.5);
    end

    % -------------------------
    % Disc contours
    % -------------------------
    D     = subject.discs;
    Cdisc = subject.centerline.discs.C;

    for d = 1:nDisc
        TR   = D.mesh(d).TR;
        xMid = Cdisc(d,1);

        loops = extractMidSagittalContour(TR, xMid);
        if isempty(loops), continue; end

        loop = getLongestLoop(loops);
        if size(loop,1) < 3, continue; end

        patch(ax, loop(:,1), loop(:,2), discColors(d,:), ...
              'FaceAlpha', 0.55, ...
              'EdgeColor', [0 0 0], ...
              'LineWidth', 0.5);
    end

    axis(ax, 'equal');
    xlabel(ax, 'Y (anterior–posterior)');
    ylabel(ax, 'Z (inferior–superior)');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL: getLongestLoop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loop = getLongestLoop(loops)
% From a cell array of loops, return the one with the most points.
% For watertight meshes this will always be the single closed contour.

    lengths = cellfun(@(L) size(L,1), loops);
    [~, idx] = max(lengths);
    loop = loops{idx};
end

