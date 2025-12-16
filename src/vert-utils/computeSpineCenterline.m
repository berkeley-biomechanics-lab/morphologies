function centerline = computeSpineCenterline(vertebrae)
% Computes a smooth spinal centerline from vertebral centroids
%
% INPUT:
%   [vertebrae.mesh(k).centroid]   [Nx3]
%
% OUTPUT:
%   centerline.ppX, ppY, ppZ     spline representations
%   centerline.C                 original centroids
%   centerline.t                 normalized arc-length parameter

    % -------------------------------------------------
    % Extract centroids (assumed anatomical order)
    % -------------------------------------------------
    C = vertcat(vertebrae.mesh.centroid);   % Nx3

    % -------------------------------------------------
    % Parameterize by cumulative arc length
    % -------------------------------------------------
    ds = vecnorm(diff(C), 2, 2);
    t = [0; cumsum(ds)];
    t = t / t(end);   % normalize to [0,1]

    % -------------------------------------------------
    % Fit cubic splines
    % -------------------------------------------------
    centerline.ppX = spline(t, C(:,1));
    centerline.ppY = spline(t, C(:,2));
    centerline.ppZ = spline(t, C(:,3));

    % -------------------------------------------------
    % Store metadata
    % -------------------------------------------------
    centerline.CVert = C;
    centerline.tVert = t; % t values (@ vertebra centroids)
end

