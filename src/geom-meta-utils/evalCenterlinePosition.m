function C = evalCenterlinePosition(centerline, t)
% Evaluate centerline position C(t)

    x = ppval(centerline.ppX, t);
    y = ppval(centerline.ppY, t);
    z = ppval(centerline.ppZ, t);

    C = [x, y, z];
end

