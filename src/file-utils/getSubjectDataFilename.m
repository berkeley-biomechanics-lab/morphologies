function fname = getSubjectDataFilename(subjectID, cfg)

    outDir = cfg.paths.rawMeasurements;
    
    if ~exist(outDir, 'dir')
        mkdir(outDir)
    end
    
    fname = fullfile(outDir, sprintf('%s.mat', subjectID));
end

