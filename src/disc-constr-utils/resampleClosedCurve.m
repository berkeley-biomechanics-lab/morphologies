function Pout = resampleClosedCurve(P, K)
% P : Nx3 ordered closed boundary (NOT duplicated at end)
% K : number of points to resample

    % 1. Remove duplicates
    P = removeDuplicatePoints(P);

    % 2. Close curve once (safe now)
    Pext = [P; P(1,:)];

    % 3. Arc-length
    d = sqrt(sum(diff(Pext,1,1).^2,2));
    s = [0; cumsum(d)];

    % 4. Enforce uniqueness (belt + suspenders)
    [s, ia] = unique(s, 'stable');
    Pext = Pext(ia,:);

    % 5. Uniform parameter
    sU = linspace(0, s(end), K+1)';
    sU(end) = [];   % remove duplicate closure

    % 6. Interpolate
    Pout = interp1(s, Pext, sU, 'linear');
end

