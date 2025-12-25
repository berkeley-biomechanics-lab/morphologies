function slices = sliceAllAxes(vert, Px, Py, Pz, kr, ignorance)

    slices.X = sliceGeometry('x', vert, Px, kr, ignorance);
    slices.Y = sliceGeometry('y', vert, Py, kr, ignorance);
    slices.Z = sliceGeometry('z', vert, Pz, kr, ignorance);
end

