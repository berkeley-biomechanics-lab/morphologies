function measure = getVolume(slicePos, CSA, name, jobInfo)
% Computing volume by integrating along the Z-plane (cranio-caudal) CSA 
% slices using the trapezoidal rule
%
% slicePos : [N×1] slice coordinates (Z)
% CSA      : [N×1] cross-sectional area
    
    valid = ~isnan(CSA) & CSA > 0;

    z = slicePos(valid);
    A = CSA(valid);

    % Sort just in case
    [z, idx] = sort(z);
    A = A(idx);

    % Trapezoidal integration
    measure = trapz(z, A);

    % ---- Progress update ----
    volumeProgressUpdate(jobInfo, name)
end

