function T = evalCenterlineTangent(centerline, t)
% Evaluate normalized centerline tangent T(t)

    dppX = fnder(centerline.ppX, 1);
    dppY = fnder(centerline.ppY, 1);
    dppZ = fnder(centerline.ppZ, 1);

    dx = ppval(dppX, t);
    dy = ppval(dppY, t);
    dz = ppval(dppZ, t);

    T = [dx, dy, dz];
    T = T ./ norm(T);

    % Imposing (-) to impose upwards direction in the local inf-sup 
    % coordinate frame:
    T = -T; 
end

