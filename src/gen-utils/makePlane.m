function plane = makePlane(axis, s, bbox)
% Construct a triangulated slicing plane
%
% plane = makePlane(axis, s, bbox)
%
% axis  : 'x', 'y', or 'z' (plane normal)
% s     : slice location along axis
% bbox  : [3x2] bounding box of geometry

    % Deconstructing bounding box:
    xmin = bbox(1,1); xmax = bbox(1,2);
    ymin = bbox(2,1); ymax = bbox(2,2);
    zmin = bbox(3,1); zmax = bbox(3,2);

    switch lower(axis)

        case 'x'  % YZ plane (x = s)
            V = [
                s ymin zmin
                s ymax zmin
                s ymax zmax
                s ymin zmax
            ];

        case 'y'  % XZ plane (y = s)
            V = [
                xmin s zmin
                xmax s zmin
                xmax s zmax
                xmin s zmax
            ];

        case 'z'  % XY plane (z = s)
            V = [
                xmin ymin s
                xmax ymin s
                xmax ymax s
                xmin ymax s
            ];

        otherwise
            error("Axis must be 'x', 'y', or 'z'");
    end

    % Two triangles (consistent winding)
    F = [
        1 2 3
        1 3 4
    ];

    plane.vertices = V;
    plane.faces    = F;
end

