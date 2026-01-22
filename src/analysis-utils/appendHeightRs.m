function rows = appendHeightRs(rows, measurements, levelNames, subjectID, isKyphotic, group, structure)

    axes = {"LAT","AP"}; measNames = axes + "r";

    if ~isfield(measurements,'height') || isempty(measurements.height)
        return;
    end

    for lvl = 1:numel(measurements.height)

        levelName = levelNames(lvl);

        for a = 1:numel(measNames)
            ax = axes{a}; measName = measNames{a};

            height = measurements.height(lvl);

            if ~isfield(height, measName)
                continue
            end

            rVal = height.(measName);

            rows(end+1,:) = { ...
                categorical(subjectID), ...
                isKyphotic, ...
                group, ...
                categorical(structure), ...
                categorical(levelName), ...
                categorical(ax), ...
                rVal};
        end
    end
end

