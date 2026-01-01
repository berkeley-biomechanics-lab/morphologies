function levels = canonicalLevels(structure)

switch lower(structure)
    case 'vertebra'
        levels = {'T1','T2','T3','T4','T5','T6','T7','T8','T9','T10', ...
                  'T11','T12','T13','T14','T15','L1','L2','L3','L4','L5','L6'};
    case 'disc'
        levels = {'T1-T2','T2-T3','T3-T4','T4-T5','T5-T6','T6-T7','T7-T8', ...
                  'T8-T9','T9-T10','T10-T11','T11-T12','T12-T13','T13-T14', ...
                  'T14-T15','T15-L1','L1-L2','L2-L3','L3-L4','L4-L5','L5-L6'};
    otherwise
        error('Unknown structure type.');
end

