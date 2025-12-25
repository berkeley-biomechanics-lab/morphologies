function selectedSubjects = getSubjectSelection(measuredSubjects, subjectNames)
% checking to see if the user-defined 'measuredSubjects' variable has been
% defined appropriately, valid formats of 'measuredSubjects' include:
%       1) "all"                        (all availible subjects)
%       3) ["643", "666", "717", ...]   (list)
%
% returns 'selectedSubjects', a formatted string array of the to-be-processed
% subjects given the user settings of 'measuredSubjects'

    % ---- OPTION 1: "all" ----
    if ischar(measuredSubjects) || (isstring(measuredSubjects) && isscalar(measuredSubjects))
        if lower(string(measuredSubjects)) == "all"
            selectedSubjects = subjectNames;
            return;
        end
        % If scalar string but not "all", fall through to Option 2
    end

    % ---- OPTION 2: Explicit list of subject IDs ----
    if isstring(measuredSubjects)

        % Convert scalar string ("643") into array form ["643"]
        measuredSubjects = string(measuredSubjects);

        % 1. Duplicate detection
        [~, ia] = unique(measuredSubjects);
        dupIdx = setdiff(1:numel(measuredSubjects), ia);
        if ~isempty(dupIdx)
            dupNames = unique(measuredSubjects(dupIdx));
            error("Duplicate subject IDs found: %s", strjoin(dupNames, ", "));
        end

        % 2. Validate existence
        for s = measuredSubjects
            if ~ismember(s, subjectNames)
                error("Invalid subject ID '%s'. Allowed subjects are: %s", ...
                    s, strjoin(subjectNames, ", "));
            end
        end

        % 3. Sort based on global ordering
        [~, idx] = ismember(measuredSubjects, subjectNames);
        [~, sortIdx] = sort(idx);
        selectedSubjects = measuredSubjects(sortIdx);

        return;
    end

    error("Invalid subject selection format. Must be ""all"" or string array of subject IDs.");
end

