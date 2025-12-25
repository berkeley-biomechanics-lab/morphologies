function plotSliceCurves(slice)

    curves  = slice.curves3D;
    overlap = slice.overlap;

    for p = 1:numel(curves)

        P = curves{p};
        plot3(P(:,1), P(:,2), P(:,3), 'k');

        F = 1:size(P,1);

        if overlap(p)
            faceColor = [1 1 1];
        else
            faceColor = [0.7 0.7 0.7];
        end

        patch( ...
            'Vertices', P, ...
            'Faces',    F, ...
            'FaceColor',faceColor, ...
            'FaceAlpha',0.4, ...
            'EdgeColor','k');
    end
end

