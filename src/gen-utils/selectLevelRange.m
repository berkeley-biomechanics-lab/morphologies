function levelsOut = selectLevelRange(structure, levelRange)

    allLevels = canonicalLevels(structure);
    
    iStart = find(strcmp(allLevels, levelRange{1}), 1);
    iEnd   = find(strcmp(allLevels, levelRange{2}), 1);
    
    if isempty(iStart) || isempty(iEnd)
        error('Requested levels not found for structure %s.', structure);
    end
    
    levelsOut = allLevels(iStart:iEnd);
end

