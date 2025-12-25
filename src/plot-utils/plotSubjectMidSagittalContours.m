function ax = plotSubjectMidSagittalContours(subject, ax)
% Plot mid-sagittal contours of vertebrae and discs into provided axes
%
% ax  : axes handle (subplot / tiledlayout)

    slabTolVert = 0.5;
    slabTolDisc = 0.5;
    
    hold(ax, 'on');

    % -------------------------
    % Color maps
    % -------------------------
    nVert = subject.vertebrae.numLevels;
    nDisc = subject.discs.numLevels;

    vertColors = parula(nVert);              % vertebrae
    discColors = autumn(nDisc) * 0.9;        % discs (warm)

    % -------------------------
    % Vertebrae contours
    % -------------------------
    V = subject.vertebrae;
    Cvert = subject.centerline.vertebrae.C;

    for i = 1:nVert
        TR = V.mesh(i).TR;
        xMid = Cvert(i,1);

        YZ = extractMidSagittalContour(TR, xMid, slabTolVert);
        if isempty(YZ), continue; end

        patch(ax, ...
            YZ(:,1), YZ(:,2), vertColors(i,:), ...
            'FaceAlpha', 0.35, ...
            'EdgeColor', [0 0 0], ...
            'LineWidth', 0.5);
    end

    % -------------------------
    % Disc contours
    % -------------------------
    D = subject.discs;
    Cdisc = subject.centerline.discs.C;

    for d = 1:nDisc
        TR = D.mesh(d).TR;
        xMid = Cdisc(d,1);

        YZ = extractMidSagittalContour(TR, xMid, slabTolDisc);
        if isempty(YZ), continue; end

        patch(ax, ...
            YZ(:,1), YZ(:,2), discColors(d,:), ...
            'FaceAlpha', 0.55, ...
            'EdgeColor', [0 0 0], ...
            'LineWidth', 0.5);
    end

    % -------------------------
    % Formatting
    % -------------------------
    axis(ax, 'equal');

    xlabel(ax, 'Y (anterior–posterior)');
    ylabel(ax, 'Z (inferior–superior)');
end

