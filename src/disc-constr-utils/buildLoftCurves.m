function Pk = buildLoftCurves(Pi, Ps, cfg)
%   Pi, Ps : K×3 ordered, closed boundary loops (same K)
%   cfg.disc.nRings        : number of interior layers
%   cfg.disc.bulgeAmp      : max bulge magnitude (mm)
%
%   Output:
%     Pk : cell array of size (nRings+2), each entry K×3

    % -------------------------------
    % Configuration settings
    % -------------------------------
    nRings = cfg.disc.nRings;
    bulgeAmplitude = cfg.disc.bulgeAmplitude;
    
    % -------------------------------
    % Basic checks
    % -------------------------------
    assert(size(Pi,1) == size(Ps,1), ...
        'Pi and Ps must have same number of boundary points');

    % -------------------------------
    % Loft parameter (0 = Pi, 1 = Ps)
    % -------------------------------
    t = linspace(0, 1, nRings+2);

    % -------------------------------
    % Disc center and radial directions
    % -------------------------------
    C = mean(Pi,1);

    R = Pi - C;
    R = R ./ vecnorm(R,2,2);  % normalize (K×3)

    % -------------------------------
    % Bulge profile (smooth & zero at ends)
    % -------------------------------
    bulgeProfile = @(s) bulgeAmplitude * sin(pi*s);

    % -------------------------------
    % Build loft curves
    % -------------------------------
    Pk = cell(numel(t),1);

    for k = 1:numel(t)
        s = t(k);

        % linear interpolation
        P = (1 - s) * Ps + s * Pi;

        % apply bulge
        P = P + bulgeProfile(s) * R;

        Pk{k} = P;
    end
end

