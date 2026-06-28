function Pk = buildLoftCurves(Pi, Ps, cfg)
%   Builds loft rings between two endplate boundary curves Pi (inferior)
%   and Ps (superior), which may have different native point counts.
%
%   Ring layout:
%     Pk{1}        = Ps          [Ks pts]    exact superior endplate
%     Pk{2:end-1}  = interior    [K_mid pts] interpolated rings
%     Pk{end}      = Pi          [Ki pts]    exact inferior endplate
%
%   Special case Ks == Ki:
%     K_mid = Ks = Ki. Interior rings are direct row-wise interpolations
%     between Ps and Pi — no resampling — so Pk{k}(i,:) is always a
%     blend of Ps(i,:) and Pi(i,:) with no arc-length distortion.
%
%   General case Ks ~= Ki:
%     K_mid = round((Ks+Ki)/2). Interior rings are resampled to K_mid.
%     The single count change (Ks→K_mid or Ki→K_mid) is handled in
%     stitchDisc via buildTransitionStrip at each end seam.

    nRings         = cfg.disc.nRings;
    bulgeAmplitude = cfg.disc.bulgeAmplitude;

    Ks = size(Ps, 1);
    Ki = size(Pi, 1);

    % Disc center (symmetric):
    C = (mean(Ps,1) + mean(Pi,1)) / 2;

    % ---------------------------
    % K_mid: common count for interior rings
    % ---------------------------
    if Ks == Ki
        K_mid = Ks;
    else
        K_mid = round((Ks + Ki) / 2);
        K_mid = max(K_mid, 8);
    end

    % ---------------------------
    % Interior loft parameters (strictly between 0 and 1)
    % ---------------------------
    t_all      = linspace(0, 1, nRings+2);
    t_interior = t_all(2:end-1);

    % ---------------------------
    % Build Pk
    % ---------------------------
    Pk      = cell(nRings+2, 1);
    Pk{1}   = Ps;
    Pk{end} = Pi;

    if Ks == Ki
        % Direct row interpolation — no resampling of Ps or Pi
        R = ((Ps-C) + (Pi-C)) / 2;
        R = R ./ max(vecnorm(R,2,2), 1e-10);

        for k = 1:nRings
            s        = t_interior(k);
            P        = (1-s)*Ps + s*Pi;
            Pk{k+1}  = P + bulgeAmplitude*sin(pi*s)*R;
        end

    else
        % Resample both to K_mid for interior interpolation only
        Ps_mid = resampleClosedCurve(Ps, K_mid);
        Pi_mid = resampleClosedCurve(Pi, K_mid);

        R = ((Ps_mid-C) + (Pi_mid-C)) / 2;
        R = R ./ max(vecnorm(R,2,2), 1e-10);

        for k = 1:nRings
            s        = t_interior(k);
            P        = (1-s)*Ps_mid + s*Pi_mid;
            Pk{k+1}  = P + bulgeAmplitude*sin(pi*s)*R;
        end
    end
end

