function [Y_control, Y_kyphotic, meta] = buildLevelStackedArray( ...
    T, measurement, axis, structure, levelRange)

    % -----------------------------
    % Resolve valid levels
    % -----------------------------
    levels = resolveLevels(structure, levelRange);

    % -----------------------------
    % Filter table
    % -----------------------------
    T = T(T.Structure == structure,:);
    T = T(T.Axis == axis,:);
    T = T(ismember(T.LevelName, levels),:);

    if isempty(T)
        error('No data after filtering.');
    end

    % -----------------------------
    % Select measurement variables
    % -----------------------------
    switch lower(measurement)
        case 'height'
            valueVar = 'Height';
        case 'csa'
            valueVar = 'CSA';
        otherwise
            error('Unknown measurement type.');
    end

    % -----------------------------
    % Group by subject + level
    % -----------------------------
    [G, subjID, lvlName] = findgroups(T.SubjectID, T.LevelName);
    nRows = max(G);

    % -----------------------------
    % Infer sampling frequency Q
    % -----------------------------
    idx1 = (G == 1);
    Q = height(T(idx1,:));

    % -----------------------------
    % Allocate full stacked array
    % -----------------------------
    Y_all = nan(nRows, Q);
    isKyphoticRow = false(nRows,1);

    % -----------------------------
    % Fill rows
    % -----------------------------
    for k = 1:nRows
        Tk = T(G == k,:);

        y = Tk.(valueVar)(:);

        if numel(y) ~= Q
            error('Inconsistent sampling frequency detected.');
        end

        Y_all(k,:) = y.';
        isKyphoticRow(k) = Tk.isKyphotic(1);
    end

    % -----------------------------
    % Split into SPM arrays
    % -----------------------------
    Y_control  = Y_all(~isKyphoticRow,:);
    Y_kyphotic = Y_all( isKyphoticRow,:);

    % -----------------------------
    % Metadata
    % -----------------------------
    meta.measurement = measurement;
    meta.axis        = axis;
    meta.structure   = structure;
    meta.levelRange  = levels;
    meta.Q           = Q;

    meta.SubjectID   = subjID;
    meta.LevelName   = lvlName;
    meta.isKyphotic  = isKyphoticRow;
end

