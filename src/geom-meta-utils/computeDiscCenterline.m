function centerline = computeDiscCenterline(subject)
% Build disc-level centerline quantities for 'subject'

    % Extracting relevant subject properties:
    centerline = subject.centerline;
    numDiscs = subject.discs.numLevels;
    discLevelNames = subject.discs.levelNames;

    % Initializing 'centerline' discs property:
    discs.C = zeros(numDiscs, 3);
    discs.t = zeros(numDiscs, 1);
    discs.T = zeros(numDiscs, 3);

    for d = 1:numDiscs
        % Getting superior and inferior vertebral t-values:
        supInd = find(subject.discs.supVertNames(d) == ...
                        subject.centerline.vertebrae.levelNames);
        infInd = find(subject.discs.infVertNames(d) == ...
                        subject.centerline.vertebrae.levelNames);
        tSup = subject.centerline.vertebrae.t(supInd);
        tInf = subject.centerline.vertebrae.t(infInd);

        % --- disc parameter (midpoint in t) ---
        discs.t(d) = 0.5 * (tSup + tInf);

        % --- disc center from spline ---
        discs.C(d,:) = evalCenterlinePosition(centerline, discs.t(d));

        % --- disc tangent ---
        discs.T(d,:) = evalCenterlineTangent(centerline, discs.t(d));
    end

    centerline.discs = discs;
    centerline.discs.levelNames = discLevelNames;
end

