function fig = plotDiscMonitor(discs, discInd, Pk, supDiscEnd, infDiscEnd, discTR, fig)
% Visualizing disc geometric properties

    % Getting disc properties:
    subjectName = discs.subjName;
    discName = discs.levelNames(discInd);

    set(0, 'CurrentFigure', fig); clf;
    title("Subject " + subjectName + ", " + discName + " Visualization");
    hold on; view(3); axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');

    % -------------------------------------------------
    % Plot endplate triangulations
    % -------------------------------------------------
    showEndplates = false;
    if showEndplates
        trisurf(supDiscEnd.TR, 'FaceColor', 'r', 'EdgeColor', 'k');
        trisurf(infDiscEnd.TR, 'FaceColor', 'b', 'EdgeColor', 'k');
    end

    % -------------------------------------------------
    % Plot all boundary points
    % -------------------------------------------------
    showBoundaries = false;
    if showBoundaries
        for k = 1:numel(Pk)
            plot3(Pk{k}(:,1), Pk{k}(:,2), Pk{k}(:,3), 'k-', 'LineWidth', 2)
        end
    end

    % -------------------------------------------------
    % Plot vertical projection lines (Ps → Pi)
    %
    % Pk rings may have variable point counts (Ks, K_mid, Ki), so we
    % cannot index row k directly across all rings. Instead, resample
    % every ring to a common count M via arc-length parametrisation,
    % then connect corresponding rows across layers.
    % -------------------------------------------------
    showProjections = false;
    if showProjections
        % Common projection count: use the minimum ring size to avoid
        % any extrapolation, then subsample for visual clarity:
        ringSizes = cellfun(@(r) size(r,1), Pk);
        M         = min(ringSizes);          % safe upper bound
        M_plot    = M;                      % show all projection lines
 
        % Resample all rings to M_plot points:
        nLayers   = numel(Pk);
        Presampled = zeros(nLayers, M_plot, 3);
 
        for s = 1:nLayers
            Presampled(s,:,:) = resampleRing(Pk{s}, M_plot);
        end
 
        % Plot one vertical line per sampled boundary point:
        for k = 1:M_plot
            Pline = squeeze(Presampled(:,k,:));   % [nLayers x 3]
            plot3(Pline(:,1), Pline(:,2), Pline(:,3), 'k-', 'LineWidth', 1.5);
        end
    end

    % -------------------------------------------------
    % Plot disc triangulation
    % -------------------------------------------------
    showDisc = true;
    if showDisc
        trisurf(discTR, 'FaceColor', [0.86 0.80 0.68], 'EdgeColor', 'None');
    end

    lighting gouraud
    camlight headlight
    material dull

    drawnow;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL: resampleRing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pout = resampleRing(P, M)
% Resample a closed 3D boundary ring to M uniformly-spaced arc-length pts.
%
% INPUTS:
%   P : [N x 3] closed boundary ring (native resolution)
%   M : desired output point count
%
% OUTPUT:
%   Pout : [M x 3] resampled ring
 
    Pext = [P; P(1,:)];
    d    = vecnorm(diff(Pext,1,1), 2, 2);
    cs   = [0; cumsum(d)];
 
    sU   = linspace(0, cs(end), M+1)';
    sU   = sU(1:end-1);   % exclude closure duplicate
 
    Pout = interp1(cs, Pext, sU, 'linear');
end

