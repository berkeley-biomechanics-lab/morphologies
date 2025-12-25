function YZ = extractMidSagittalContour(TR, xMid, tol)

    P = TR.Points;

    mask = abs(P(:,1) - xMid) < tol;
    Pslab = P(mask,:);

    if size(Pslab,1) < 30
        YZ = [];
        return
    end

    YZraw = Pslab(:,2:3);
    K = boundary(YZraw(:,1), YZraw(:,2), 0.4);
    YZ = YZraw(K,:);
end

