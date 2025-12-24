function R = rotationFromTangent(T)

    ez = T(:) / norm(T);

    eref = [0; 1; 0];
    if abs(dot(ez, eref)) > 0.9
        eref = [1; 0; 0];
    end

    ex = cross(eref, ez);
    ex = ex / norm(ex);

    ey = cross(ez, ex);

    R = [ex';
         ey';
         ez'];
end

