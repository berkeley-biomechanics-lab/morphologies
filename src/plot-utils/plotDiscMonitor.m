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
    % Plot vertical projection lines (Pi → Ps)
    % -------------------------------------------------
    showProjections = false;
    if showProjections
        K = length(Pk{1});

        for k = 1:K
            Pline = zeros(numel(Pk),3);
            for s = 1:numel(Pk)
                Pline(s,:) = Pk{s}(k,:);
            end
        
            plot3(Pline(:,1), Pline(:,2), Pline(:,3), 'k-', 'LineWidth', 1.5)
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

