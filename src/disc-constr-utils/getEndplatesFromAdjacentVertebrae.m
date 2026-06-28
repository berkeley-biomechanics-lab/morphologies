function [supDiscEnd, infDiscEnd] = getEndplatesFromAdjacentVertebrae( ...
            supVertMesh, infVertMesh, centerline, cfg, discIdx)
%   Extracts endplates and performs ONE combined alignment of Pi to Ps:
%     Step 1 — Winding: flip Pi if it traverses opposite to Ps
%     Step 2 — Phase:   circularly shift Pi so Pi(1,:) angularly matches
%                       Ps(1,:)
%
%   Only Pi is ever modified. Ps is the fixed reference.
%   No resampling — Ps and Pi retain native point counts Ks and Ki.

    CDisc = centerline.discs.C(discIdx, :);
    TDisc = centerline.discs.T(discIdx, :);

    supDiscEnd = extractEndplate(supVertMesh, CDisc, TDisc, "inf", cfg);
    infDiscEnd = extractEndplate(infVertMesh, CDisc, TDisc, "sup", cfg);

    if isempty(supDiscEnd.TR.Points) || isempty(infDiscEnd.TR.Points)
        error("getEndplatesFromAdjacentVertebrae: endplate extraction " + ...
              "failed for %s-%s.", ...
              supVertMesh.levelName, infVertMesh.levelName);
    end

    Ps = supDiscEnd.Pb;   % reference — never modified
    Pi = infDiscEnd.Pb;   % will be aligned to Ps

    % ---------------------------------------------------------
    % Combined alignment: winding then phase
    % Ps is the reference. Pi is brought into agreement with Ps.
    % ---------------------------------------------------------
    Pi = alignToReference(Ps, Pi);

    supDiscEnd.Pb = Ps;
    infDiscEnd.Pb = Pi;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL: alignToReference
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pi_out = alignToReference(Ps, Pi)
% Align Pi to match Ps in both traversal direction and start index.
% Ps is unchanged. Pi may be flipped and/or circularly shifted.
%
% Step 1 — Winding alignment:
%   Project both loops to a shared plane. Compute signed area of each.
%   If they have opposite signs, flip Pi (reverse traversal direction).
%
% Step 2 — Phase alignment:
%   Find the circular shift of Pi that minimises total point-to-point
%   distance to Ps (after resampling to a common count for comparison).
%   This is more robust than angle-matching for non-convex loops.

    % ------------------------------------------------------------------
    % Shared projection plane via PCA on combined point set
    % ------------------------------------------------------------------
    C    = (mean(Ps,1) + mean(Pi,1)) / 2;
    Xall = [(Ps-C); (Pi-C)];
    [U,~,~] = svd(Xall' * Xall);   % U(:,1:2) = in-plane axes

    Ps2d = (Ps-C) * U(:,1:2);   % [Ks x 2]
    Pi2d = (Pi-C) * U(:,1:2);   % [Ki x 2]

    % ------------------------------------------------------------------
    % Step 1: Winding alignment
    % Signed area via shoelace formula in 2D:
    % ------------------------------------------------------------------
    windingSign = @(P2d) sign(sum(P2d(:,1).*circshift(P2d(:,2),-1) - ...
                                  circshift(P2d(:,1),-1).*P2d(:,2)));

    ws = windingSign(Ps2d);
    wi = windingSign(Pi2d);

    if ws * wi < 0
        % Opposite winding: reverse Pi
        Pi   = flipud(Pi);
        Pi2d = flipud(Pi2d);
    end

    % ------------------------------------------------------------------
    % Step 2: Phase alignment via minimum total distance
    % Resample both to a common count for comparison only —
    % the actual Pi returned retains its native Ki points.
    % ------------------------------------------------------------------
    Ki  = size(Pi, 1);
    Ks  = size(Ps, 1);
    K_compare = max(Ks, Ki);

    % Arc-length parametrise Pi2d for resampling:
    Pi2d_rs = resample2d(Pi2d, K_compare);   % [K_compare x 2]
    Ps2d_rs = resample2d(Ps2d, K_compare);   % [K_compare x 2]

    % Try all circular shifts of Pi2d_rs and pick the one that minimises
    % sum of squared distances to Ps2d_rs:
    bestCost  = Inf;
    bestShift = 0;

    for shift = 0:K_compare-1
        Pi_shifted = circshift(Pi2d_rs, shift, 1);
        cost       = sum(sum((Pi_shifted - Ps2d_rs).^2));
        if cost < bestCost
            bestCost  = cost;
            bestShift = shift;
        end
    end

    % Apply the same shift (scaled to Ki) to the native Pi:
    % Convert bestShift from K_compare space to Ki space:
    nativeShift = round(bestShift * Ki / K_compare);
    Pi_out      = circshift(Pi, nativeShift, 1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL: resample2d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pout = resample2d(P, K)
% Resample a 2D closed curve to K uniformly-spaced arc-length points.
    P    = [P; P(1,:)];
    d    = vecnorm(diff(P,1,1), 2, 2);
    cs   = [0; cumsum(d)];
    sU   = linspace(0, cs(end), K+1)';
    sU   = sU(1:end-1);
    Pout = interp1(cs, P, sU, 'linear');
end

