function discTR = stitchDisc(Pk, TRs, TRi)
%   Stitches lofted disc boundary curves into a closed triangulated surface.
%
%   Pk{1} and Pk{end} have native counts Ks and Ki. Interior rings have
%   K_mid. Adjacent ring pairs are either uniform (same count → standard
%   quad strip) or transitioning (different count → transition strip).
%
%   The endplate caps TRs and TRi are appended and seam vertices fused
%   via mergeCloseVertices.

    K = numel(Pk);

    % =================================================================
    % 1. Stack all loft-ring vertices
    % =================================================================
    nPts      = sum(cellfun(@(p) size(p,1), Pk));
    V         = zeros(nPts, 3);
    ringStart = zeros(K, 1);

    cursor = 0;
    for k = 1:K
        n = size(Pk{k}, 1);
        V(cursor+1:cursor+n, :) = Pk{k};
        ringStart(k) = cursor + 1;
        cursor = cursor + n;
    end

    % =================================================================
    % 2. Side-wall faces
    % =================================================================
    Fside = zeros(0, 3);

    for k = 1:K-1
        nA = size(Pk{k},   1);
        nB = size(Pk{k+1}, 1);

        if nA == nB
            Fside = [Fside; buildUniformStrip(ringStart(k), ringStart(k+1), nA)]; %#ok<AGROW>
        else
            Fside = [Fside; buildTransitionStrip(Pk{k}, Pk{k+1}, ringStart(k), ringStart(k+1))]; %#ok<AGROW>
        end
    end

    % =================================================================
    % 3. Append endplate caps
    % =================================================================
    nV = size(V,1);

    Vi = TRi.Points;
    Fi = TRi.ConnectivityList + nV;
    V  = [V; Vi];

    Vs = TRs.Points;
    Fs = TRs.ConnectivityList + size(V,1);
    V  = [V; Vs];

    % =================================================================
    % 4. Combine, clean, merge seam vertices
    % =================================================================
    F = [Fside; Fi; Fs];
    F = removeDegenerateFaces(F, V);

    [V, F] = mergeCloseVertices(V, F, 1e-6);

    discTR = triangulation(F, V);

    % =================================================================
    % 5. Watertightness check
    % =================================================================
    Fb = freeBoundary(discTR);
    if ~isempty(Fb)
        warning('stitchDisc: %d open boundary edges remain.', size(Fb,1));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL: buildUniformStrip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function F = buildUniformStrip(startA, startB, n)
% Quad strip between two rings of equal count n.

    F   = zeros(2*n, 3);
    row = 1;
    for i = 0:n-1
        i2 = mod(i+1, n);
        v1 = startA + i;
        v2 = startA + i2;
        v3 = startB + i;
        v4 = startB + i2;
        F(row,   :) = [v1, v3, v2];
        F(row+1, :) = [v2, v3, v4];
        row = row + 2;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL: buildTransitionStrip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function F = buildTransitionStrip(ringA, ringB, startA, startB)
% Connect two rings of different counts using monotone arc-length pointer.

    nA = size(ringA, 1);
    nB = size(ringB, 1);

    if nA >= nB
        nDense  = nA;  startDense  = startA;  ringDense  = ringA;
        nSparse = nB;  startSparse = startB;
        flipWinding = false;
    else
        nDense  = nB;  startDense  = startB;  ringDense  = ringB;
        nSparse = nA;  startSparse = startA;
        flipWinding = true;
    end

    tD = arcLengthParam(ringDense);
    if flipWinding
        tS = arcLengthParam(ringA);
    else
        tS = arcLengthParam(ringB);
    end

    F   = zeros(nDense + nSparse, 3);
    row = 1;
    iD  = 0;
    iS  = 0;

    for step = 1:(nDense + nSparse)
        iD_next = mod(iD+1, nDense);
        iS_next = mod(iS+1, nSparse);

        tD_next = tD(iD_next+1); if iD_next == 0, tD_next = 1.0; end
        tS_next = tS(iS_next+1); if iS_next == 0, tS_next = 1.0; end

        vD1 = startDense  + iD;
        vS1 = startSparse + iS;
        vD2 = startDense  + iD_next;
        vS2 = startSparse + iS_next;

        advD = tD_next <= tS_next + 1e-10;
        advS = tS_next <= tD_next + 1e-10;

        if advD && advS
            F(row,  :) = [vD1, vD2, vS1];
            F(row+1,:) = [vD2, vS2, vS1];
            row = row + 2;
            iD = iD_next;
            iS = iS_next;
        elseif advD
            F(row,:) = [vD1, vD2, vS1];
            row = row + 1;
            iD = iD_next;
        else
            F(row,:) = [vD1, vS2, vS1];
            row = row + 1;
            iS = iS_next;
        end

        if iD == 0 && iS == 0, break; end
    end

    F = F(1:row-1, :);

    if flipWinding
        F = F(:,[1,3,2]);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL: arcLengthParam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = arcLengthParam(P)
    Pext = [P; P(1,:)];
    d    = vecnorm(diff(Pext,1,1), 2, 2);
    cs   = [0; cumsum(d)];
    t    = cs(1:end-1) / cs(end);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL: mergeCloseVertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Vout, Fout] = mergeCloseVertices(V, F, tol)
    scale = 1/tol;
    Vr    = round(V*scale)/scale;
    [Vout, ~, ic] = unique(Vr, 'rows', 'stable');
    Fout  = ic(F);
    Fout  = removeDegenerateFaces(Fout, Vout);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL: removeDegenerateFaces
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function F = removeDegenerateFaces(F, V)
    degen = F(:,1)==F(:,2) | F(:,2)==F(:,3) | F(:,1)==F(:,3);
    F = F(~degen,:);
    if isempty(F), return; end
    v1    = V(F(:,1),:);
    v2    = V(F(:,2),:);
    v3    = V(F(:,3),:);
    areas = 0.5*vecnorm(cross(v2-v1,v3-v1,2),2,2);
    F     = F(areas > 1e-12,:);
end

