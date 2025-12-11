function selectedLevels = getLevelSelection(measuredLevels, allLevelNames)
% checking to see if the user-defined 'measuredLevels' variable has been
% defined appropriately, valid formats of 'measuredLevels' include:
%       1) "all"                     (all availible levels)
%       2) "<start> - <end>"         (range)
%       3) ["T1","T5",...]           (list)
%
% returns 'selectedLevels', a formatted string array of the to-be-processed
% levels given the user settings of 'measuredLevels'

    % Coerce char → string, for safety
    if ischar(measuredLevels)
        measuredLevels = string(measuredLevels);
    end

    % ---- OPTION 1: "all" ----
    if isstring(measuredLevels) && isscalar(measuredLevels) ...
            && measuredLevels == "all"

        selectedLevels = allLevelNames;
        return;
    end

    % ---- OPTION 2: "<start> - <end>" ----
    rangeExpr = "^\s*(T|L)\d+\s*-\s*(T|L)\d+\s*$";

    if isstring(measuredLevels) && isscalar(measuredLevels) ...
            && ~isempty(regexp(measuredLevels, rangeExpr, "once"))

        parts = split(measuredLevels, "-");
        startLevel = strtrim(parts(1));
        endLevel   = strtrim(parts(2));

        % Validate names
        if ~ismember(startLevel, allLevelNames)
            error("Invalid start level '%s'. Must be one of: %s", ...
                startLevel, strjoin(allLevelNames, ", "));
        end

        if ~ismember(endLevel, allLevelNames)
            error("Invalid end level '%s'. Must be one of: %s", ...
                endLevel, strjoin(allLevelNames, ", "));
        end

        % Compute index range
        startIdx = find(allLevelNames == startLevel);
        endIdx   = find(allLevelNames == endLevel);

        if startIdx > endIdx
            error("Invalid range: '%s' to '%s' (start must precede end).", ...
                startLevel, endLevel);
        end

        selectedLevels = allLevelNames(startIdx:endIdx);
        return;
    end

    % ---- OPTION 3: Explicit list ["T2","T5",...] ----
    if isstring(measuredLevels) && ...
       (numel(measuredLevels) > 1 || (isscalar(measuredLevels) && measuredLevels ~= "all" ...
            && isempty(regexp(measuredLevels, rangeExpr, "once"))))
    
        % 1. Check for duplicates
        [~, ia] = unique(measuredLevels);
        dupIdx = setdiff(1:numel(measuredLevels), ia);
        if ~isempty(dupIdx)
            dupNames = unique(measuredLevels(dupIdx));
            error("Measured level list contains duplicates: %s", ...
                strjoin(dupNames, ", "));
        end
    
        % 2. Validate entries
        for lvl = measuredLevels
            if ~ismember(lvl, allLevelNames)
                error("Invalid level '%s'. Allowed levels: %s", ...
                    lvl, strjoin(allLevelNames, ", "));
            end
        end
    
        % 3. Sort using anatomical order
        [~, order] = ismember(measuredLevels, allLevelNames);
        [~, sortIdx] = sort(order);
    
        selectedLevels = measuredLevels(sortIdx);
        return;
    end 

    error("Invalid format for measuredLevels. See documentation.");
end

