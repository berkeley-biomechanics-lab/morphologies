function varName = resolveMeasurementVar(measurementType, axisType)

measurementType = lower(measurementType);
axisType = upper(axisType);

switch measurementType
    case 'height'
        validAxes = {'LAT','AP'};
        if ~ismember(axisType, validAxes)
            error('Height axis must be LAT or AP.');
        end
        varName = ['Height_' axisType];

    case 'csa'
        validAxes = {'X','Y','Z'};
        if ~ismember(axisType, validAxes)
            error('CSA axis must be X, Y, or Z.');
        end
        varName = ['CSA_' axisType];

    otherwise
        error('Unknown measurement type: %s', measurementType);
end

