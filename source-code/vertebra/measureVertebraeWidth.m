%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the polyshapes at all slices of a vertebrae, this program
% measures the AP and lateral widths of each slice.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% script variables:
varsbefore = who;

%% Loop through all slices and measure widths

nsl = indices(2) - indices(1);
wAPslices = zeros(nsl, 1);
wlatslices = zeros(nsl, 1);
zAPslices = zeros(nsl, 1);
zlatslices = zeros(nsl, 1);

for kk = indices(1):indices(2)
    pgon = sls(kk);
    x2D = pgon.Vertices(:,1);
    y2D = pgon.Vertices(:,2);
    [ctrX, ctrY] = centroid(pgon);

    % % LATERAL WIDTH
    % finding boundaries of 2D domain:
    [leftX, ~] = min(x2D); % minimum x-position in mesh grid
    [rightX, ~] = max(x2D); % maximum x-position in mesh grid
    latY = ctrY; % y-position of lat midline, midsection point as reference

    % characterizing 2D domain (unknown AP dimension):
    antposX = linspace(leftX, rightX, nh);
    antposY = linspace(latY, latY, nh);
    inPgon = isinterior(pgon, antposX, antposY); % lateralX, lateralY: query points
    xdomain = antposX(inPgon); % domain of x-coordinates inside boundary @ y = latY
    lX = min(xdomain); % left lateral x-position
    rX = max(xdomain); % right lateral x-position

    % % ANTERIOR-POSTERIOR WIDTH
    % finding boundaries of 2D domain:
    [antY, ~] = min(y2D); % minimum y-position in mesh grid
    [posY, ~] = max(y2D); % maximum y-position in mesh grid
    apX = ctrX; % x-position of AP midline, midsection point as reference

    % characterizing 2D domain (unknown AP dimension):
    antposX = linspace(apX, apX, nh);
    antposY = linspace(antY, posY, nh);
    inPgon = isinterior(pgon, antposX, antposY); % antposX, antposY: query points
    ydomain = antposY(inPgon); % domain of y-coordinates inside boundary @ x = apX
    aY = min(ydomain); % anterior y-position
    pY = max(ydomain); % posterior y-position

    % calculation
    wAP = abs(pY - aY);
    wlat = abs(rX - lX);
    wAPslices(kk-indices(1)+1) = wAP;
    wlatslices(kk-indices(1)+1) = wlat;
    zAPslices(kk-indices(1)+1) = Zs{ii}{jj}(kk);
    zlatslices(kk-indices(1)+1) = Zs{ii}{jj}(kk);
end

% interpolating measurement arrays to a size of ns x 1:
dwAP = abs(diff(wAPslices)); swAP = [0; cumsum(dwAP)]; swAP_interp = linspace(0, swAP(end), ns); % cumulative arc length
dwlat = abs(diff(wlatslices)); swlat = [0; cumsum(dwlat)]; swlat_interp = linspace(0, swlat(end), ns); % cumulative arc length
dzAP = abs(diff(zAPslices)); szAP = [0; cumsum(dzAP)]; szAP_interp = linspace(0, szAP(end), ns); % cumulative arc length
dzlat = abs(diff(zlatslices)); szlat= [0; cumsum(dzlat)]; szlat_interp = linspace(0, szlat(end), ns); % cumulative arc length

wAPslices = interp1(swAP, wAPslices, swAP_interp, 'linear')';
wlatslices = interp1(swlat, wlatslices, swlat_interp, 'linear')';
zAPslices = interp1(szAP, zAPslices, szAP_interp, 'linear')';
zlatslices = interp1(szlat, zlatslices, szlat_interp, 'linear')';

% normalizing inf-sup z-axis to 0:
zAPslices = zAPslices - min(zAPslices);
zlatslices = zlatslices - min(zlatslices);

%% MATLAB cleanup

% deleting everything except wAP and wlat:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'wAPslices', 'wlatslices', 'zAPslices', 'zlatslices'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
