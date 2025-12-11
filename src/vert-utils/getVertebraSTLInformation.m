function [vertebraSTLData, selectedSubjectsCopy] = getVertebraSTLInformation(vertPath, selectedSubjects, selectedLevels)
% Return array of structs, one per subject, describing the subjects' 
% vertebrae information and also string array of selected subject names.
% Each struct contains:
%   --> .vertebrae.subjName
%   --> .vertebrae.levelNames
%   --> .vertebrae.levelPaths
%   --> .vertebrae.numLevels

    % Making copies of input subject variable:
    selectedSubjectsCopy = selectedSubjects;

    % -----------------------------------------------------------
    % 1. Get all subject folders present in vertPath
    % -----------------------------------------------------------
    d = dir(vertPath);
    isDir = [d.isdir];
    folders = string({d(isDir).name});
    folders = folders(folders ~= "." & folders ~= "..");

    vertPathSubjects = folders;  % available subjects

    % -----------------------------------------------------------
    % 2. Determine subjects to process
    % -----------------------------------------------------------
    % ALREADY CHECKED: any invalid subject ID i.e. '123'. Allowed subjects 
    % are: 643, 658, 660, 665, 666, 717, 723, 735, 743, 764, 765, 766, 778,
    % and 779. Making checks for any differences between subject selections
    % and directory availibility:
    diffSubjs = setdiff(selectedSubjectsCopy, vertPathSubjects);
    if ~isempty(diffSubjs)
        if (numel(diffSubjs) == numel(selectedSubjectsCopy)) && ...
                (all(diffSubjs == selectedSubjectsCopy))
            error("Invalid subject selection format. None of the selected " + ...
                        "subjects are in the vertebral geometry path!");
        else
            overlapMask = ismember(selectedSubjectsCopy, diffSubjs);
            selectedSubjectsCopy(overlapMask) = [];
        end
    end

    % -----------------------------------------------------------
    % 3. Build the subjectData output
    % -----------------------------------------------------------
    vertebraSTLData = repmat(struct(), numel(selectedSubjectsCopy), 1);

    for i = 1:numel(selectedSubjectsCopy)

        selectedLevelsCopy = selectedLevels; % resetting copy of selectedLevels

        subjName = selectedSubjectsCopy(i);
        subjPath = fullfile(vertPath, subjName);

        % -------------------------------------------------------
        % Find all available STL files for this subject
        % -------------------------------------------------------
        stlFiles = dir(fullfile(subjPath, '*.stl'));
        allSTLnames = string({stlFiles.name});

        % Extract vertebra codes (e.g., "T3", "L1")
        availableLevels = extractBefore(allSTLnames, ".stl");
        [availableLevelsSorted, ~] = sortVertebralLevels(availableLevels);

        % -------------------------------------------------------
        % Filter STLs according to selected levels
        % -------------------------------------------------------
        % ALREADY CHECKED: any invalid level name i.e. 'A3'. Allowed levels 
        % are: T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14,
        % T15, L1, L2, L3, L4, L5, L6. Making checks for any differences 
        % between level selections and directory availibility:
        diffLevels = setdiff(selectedLevels, availableLevelsSorted);
        [diffLevelsSorted, ~] = sortVertebralLevels(diffLevels);
        if ~isempty(diffLevels)
            if (numel(diffLevelsSorted) == numel(selectedLevels)) && ...
                    (all(diffLevelsSorted == selectedLevels))
                error("Invalid level selection format. None of the selected " + ...
                            "levels are in the vertebral geometry subject path!");
            else
                overlapMask = ismember(selectedLevelsCopy, diffLevelsSorted);
                selectedLevelsCopy(overlapMask) = [];
            end
        end

        selectedSTLnames = selectedLevelsCopy + ".stl";
        selectedPaths = fullfile(subjPath, selectedSTLnames);

        % -------------------------------------------------------
        % Construct per-subject struct
        % -------------------------------------------------------
        vertebraSTLData(i).vertebrae.subjName = subjName;

        vertebraSTLData(i).vertebrae.levelNames = selectedLevelsCopy;
        vertebraSTLData(i).vertebrae.levelPaths = selectedPaths;
        vertebraSTLData(i).vertebrae.numLevels = numel(selectedLevelsCopy);
    end
end

