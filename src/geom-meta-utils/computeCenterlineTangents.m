function centerline = computeCenterlineTangents(subject)
% Computes unit tangent vectors of the spine centerline
% at vertebral centroid locations
%
% INPUT:
%   subject.centerline.ppX, ppY, ppZ   spline structs
%   subject.centerline.tVert           vertebral parameters
%
% OUTPUT (added to centerline):
%   centerline.TVert(i,:)      unit tangent at vertebra i

    centerline = subject.centerline;
    vertLevelNames = subject.vertebrae.levelNames;

    % -------------------------------------------------
    % Compute spline derivatives
    % -------------------------------------------------
    dppX = fnder(centerline.ppX, 1);
    dppY = fnder(centerline.ppY, 1);
    dppZ = fnder(centerline.ppZ, 1);

    t = centerline.vertebrae.t;
    nV = numel(t);

    T = zeros(nV,3);

    % -------------------------------------------------
    % Evaluate tangents at vertebrae
    % -------------------------------------------------
    for i = 1:nV
        Tx = ppval(dppX, t(i));
        Ty = ppval(dppY, t(i));
        Tz = ppval(dppZ, t(i));

        Ti = [Tx Ty Tz];

        % Normalize
        T(i,:) = Ti / norm(Ti);
    end

    % Imposing (-) to impose upwards direction in the local inf-sup 
    % coordinate frame:
    centerline.vertebrae.T = -T;
    centerline.vertebrae.levelNames = vertLevelNames;
end

