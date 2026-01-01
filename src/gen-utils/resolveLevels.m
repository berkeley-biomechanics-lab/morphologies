function levels = resolveLevels(structure, levelRange)
% Resolve a vertebral level range into structure-specific labels
%
% INPUT
% -----
% structure  : 'vertebra' | 'disc'
% levelRange : ["T12","L3"]
%
% OUTPUT
% ------
% levels     : categorical-compatible string array

    % -----------------------------
    % Canonical ordered spine
    % -----------------------------
    spine = [ ...
        "T1","T2","T3","T4","T5","T6","T7","T8","T9","T10","T11","T12", ...
        "T13","T14","T15", ...
        "L1","L2","L3","L4","L5","L6" ];

    % -----------------------------
    % Validate input
    % -----------------------------
    if numel(levelRange) ~= 2
        error('levelRange must be ["start","end"].');
    end

    i1 = find(spine == levelRange(1), 1);
    i2 = find(spine == levelRange(2), 1);

    if isempty(i1) || isempty(i2) || i1 > i2
        error('Invalid level range.');
    end

    % -----------------------------
    % Resolve by structure
    % -----------------------------
    switch lower(structure)

        case 'vertebra'
            levels = spine(i1:i2);

        case 'disc'
            verts = spine(i1:i2);

            if numel(verts) < 2
                error('Disc range must span at least two vertebrae.');
            end

            levels = strings(numel(verts)-1,1);
            for k = 1:numel(verts)-1
                levels(k) = verts(k) + "-" + verts(k+1);
            end

        otherwise
            error('Unknown structure type.');
    end
end

