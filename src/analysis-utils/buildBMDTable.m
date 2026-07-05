function Tbmd = buildBMDTable(csvPath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: buildBMDTable.m
% Author: Yousuf Abubakr
% Project: Morphologies
%
% Description:
%   Reads the BMD mean measurements CSV and organizes it into a long-format
%   table consistent with the other measurement tables (Tslice, Theight,
%   Tvolume) used in summarizeData.m.
%
%   CSV format:
%     Row 1  : header — "Level", then group labels ("Kyph" x 6, "Ctrl" x 8)
%     Rows 2+: one spinal level per row, BMD values per subject column
%     Missing: encoded as "#N/A" strings
%
% INPUT:
%   csvPath : full path to 'bmd-mean-measurements.csv'
%
% OUTPUT:
%   Tbmd : table with columns:
%     SubjectID  : categorical  — anonymous subject index per group
%     isKyphotic : logical      — true if kyphotic
%     Group      : categorical  — 'kyphotic' | 'control'
%     Structure  : categorical  — always 'vertebra' (BMD is per vertebra)
%     LevelName  : categorical  — e.g. 'T1', 'L3'
%     BMD        : double       — mean BMD value (HU or mgHA/cm³)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % ------------------------------------------------------------------
    % 1. Read raw CSV
    % ------------------------------------------------------------------
    raw = readcell(csvPath, 'MissingRule', 'fill');
    % readcell preserves strings like '#N/A' as char — convert to NaN below

    % ------------------------------------------------------------------
    % 2. Parse header row for subject IDs and group assignments
    %    Header format: '{subjectID}k' or '{subjectID}c'
    %    e.g. '658k' → subjectID='658', isKyphotic=true
    %         '743c' → subjectID='743', isKyphotic=false
    % ------------------------------------------------------------------
    headerRow   = raw(1, :);
    colHeaders  = string(headerRow(2:end));   % drop 'Level' column
    nSubjects   = numel(colHeaders);

    subjectIDs    = strings(1, nSubjects);
    isKyphoticCol = false(1, nSubjects);

    for s = 1:nSubjects
        hdr = char(colHeaders(s));

        % Last character is the group suffix ('k' or 'c'):
        suffix = hdr(end);
        id     = hdr(1:end-1);   % everything before the suffix

        subjectIDs(s)    = string(id);
        isKyphoticCol(s) = strcmpi(suffix, 'k');
    end

    % ------------------------------------------------------------------
    % 3. Parse level rows into long-format rows
    % ------------------------------------------------------------------
    levelRows = raw(2:end, :);   % all data rows
    nLevels   = size(levelRows, 1);

    rows = {};   % will grow: {SubjectID, isKyphotic, Group, Structure, LevelName, BMD}

    for lvl = 1:nLevels
        levelName = string(levelRows{lvl, 1});   % e.g. 'T1', 'L3'

        for s = 1:nSubjects
            rawVal = levelRows{lvl, s+1};   % +1 to skip Level column

            % Handle missing values (#N/A stored as char, string, or NaN):
            if isnumeric(rawVal) && isscalar(rawVal) && isnan(rawVal)
                bmdVal = NaN;
            elseif ischar(rawVal) || isstring(rawVal)
                strim = strtrim(char(rawVal));
                if strcmpi(strim, '#N/A') || strcmpi(strim, 'N/A')
                    bmdVal = NaN;
                else
                    bmdVal = str2double(strim);
                end
            elseif isnumeric(rawVal)
                bmdVal = double(rawVal);
            else
                bmdVal = NaN;
            end

            isKyph = isKyphoticCol(s);
            grp    = categorical(string(ternary(isKyph, "kyphotic", "control")));
            subjID = categorical(subjectIDs(s));

            rows(end+1, :) = { ...
                subjID, ...
                isKyph, ...
                grp, ...
                categorical("vertebra"), ...
                categorical(levelName), ...
                bmdVal};
        end
    end

    % ------------------------------------------------------------------
    % 4. Build table
    % ------------------------------------------------------------------
    Tbmd = cell2table(rows, 'VariableNames', ...
        {'SubjectID', 'isKyphotic', 'Group', 'Structure', 'LevelName', 'BMD'});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL: ternary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = ternary(cond, a, b)
    if cond, out = a; else, out = b; end
end

