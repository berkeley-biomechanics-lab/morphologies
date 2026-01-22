function [Tslice, Theight, Tvolume, Theightrs] = buildMeasurementTables(cfg)

    measureDir = cfg.paths.rawMeasurements;
    files = dir(fullfile(measureDir, '*.mat'));

    rows_slice  = {};
    rows_height = {};
    rows_volume = {};
    rows_heightrs = {};

    for f = 1:numel(files)

        tmp  = load(fullfile(files(f).folder, files(f).name));
        subj = tmp.subject;

        subjectID  = string(subj.name);
        isKyphotic = logical(subj.isKyphotic);

        if isKyphotic
            group = categorical("kyphotic");
        else
            group = categorical("control");
        end

        % ---------------- Vertebrae ----------------
        if isfield(subj,'vertebrae') && isfield(subj.vertebrae,'measurements')

            levelNames = subj.vertebrae.levelNames;
            meas       = subj.vertebrae.measurements;

            rows_slice  = appendSlices(rows_slice,  meas, levelNames, subjectID, isKyphotic, group, "vertebra");
            rows_height = appendHeights(rows_height, meas, levelNames, subjectID, isKyphotic, group, "vertebra");
            rows_volume = appendVolumes(rows_volume, meas, levelNames, subjectID, isKyphotic, group, "vertebra");
            rows_heightrs = appendHeightRs(rows_heightrs, meas, levelNames, subjectID, isKyphotic, group, "vertebra");
        end

        % ---------------- Discs ----------------
        if isfield(subj,'discs') && isfield(subj.discs,'measurements')

            levelNames = subj.discs.levelNames;
            meas       = subj.discs.measurements;

            rows_slice  = appendSlices(rows_slice,  meas, levelNames, subjectID, isKyphotic, group, "disc");
            rows_height = appendHeights(rows_height, meas, levelNames, subjectID, isKyphotic, group, "disc");
            rows_volume = appendVolumes(rows_volume, meas, levelNames, subjectID, isKyphotic, group, "disc");
            rows_heightrs = appendHeightRs(rows_heightrs, meas, levelNames, subjectID, isKyphotic, group, "disc");
        end
    end

    % ---- Build tables ----
    Tslice = cell2table(rows_slice, 'VariableNames', ...
        {'SubjectID','isKyphotic','Group','Structure','LevelName','Axis', ...
         'SliceIdx','SlicePos','CSA','Width1','Width2'});

    Theight = cell2table(rows_height, 'VariableNames', ...
        {'SubjectID','isKyphotic','Group','Structure','LevelName','Axis', ...
        'CoordIdx','Coord','Height'});

    Tvolume = cell2table(rows_volume, 'VariableNames', ...
        {'SubjectID','isKyphotic','Group','Structure','LevelName','Volume'});

    Theightrs = cell2table(rows_heightrs, 'VariableNames', ...
        {'SubjectID','isKyphotic','Group','Structure','LevelName', 'Axis','HeightR'});
end

