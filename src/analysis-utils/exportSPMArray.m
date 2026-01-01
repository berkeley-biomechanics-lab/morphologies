function exportSPMArray(outDir, name, Y_control, Y_kyphotic, meta)
% Writes SPM-ready arrays to disk for Python processing.
%
% INPUTS
% -------
% outDir      : output directory
% name        : base filename (no extension)
% Y_control   : [Nc x Q] double
% Y_kyphotic  : [Nk x Q] double
% meta        : struct with fields:
%               .levels
%               .axis
%               .measurement
%               .structure
%               .notes (optional)

    arguments
        outDir (1,:) char
        name   (1,:) char
        Y_control double
        Y_kyphotic double
        meta struct
    end

    if ~exist(outDir,'dir')
        mkdir(outDir);
    end

    export = struct();
    export.Y_control    = Y_control;
    export.Y_kyphotic   = Y_kyphotic;

    export.levels       = meta.levels;
    export.axis         = meta.axis;
    export.measurement  = meta.measurement;
    export.structure    = meta.structure;

    export.meta.timestamp = datetime('now');
    if isfield(meta,'notes')
        export.meta.notes = meta.notes;
    end

    save(fullfile(outDir, name + ".mat"), ...
         "export", "-v7.3");

    fprintf("✔ Exported %s (%s | %s | %s)\n", ...
        name, meta.measurement, meta.structure, meta.axis);
end

