function discData = getDiscInformation(discPath, vertebraData, allLevelNames)
% Return array of structs, 'discData', describing the subjects' 
% disc information and also string array of selected subject names.
% Each struct contains:
%   --> .discs.subjName
%   --> .discs.levelNames
%   --> .discs.levelPaths
%   --> .discs.numLevels

    % -----------------------------------------------------------
    % Build the discData output
    % -----------------------------------------------------------
    discData = repmat(struct(), numel(vertebraData), 1);

    for i = 1:numel(vertebraData)

        subjName = vertebraData(i).vertebrae.subjName;
        vertebraNames = vertebraData(i).vertebrae.levelNames;

        % Convert to index positions in global anatomical ordering
        [~, idx] = ismember(vertebraNames, allLevelNames);
    
        % Loop over list and check anatomical adjacency
        discNames = strings(0,1);
        supVertNames = strings(0,1); % superior vertebrae relative to disc, i.e. disc = "T6-T7", sup vert = "T6"
        infVertNames = strings(0,1); % inferior vertebrae relative to disc, i.e. disc = "T6-T7", sup vert = "T7"
        for k = 1:numel(idx)-1
            if idx(k+1) == idx(k) + 1
                % These two vertebrae are properly adjacent → valid disc
                discNames(end+1,1) = vertebraNames(k) + "-" + vertebraNames(k+1);

                % Storing superior and inferior vertebrae names:
                supVertNames(end+1,1) = vertebraNames(k);
                infVertNames(end+1,1) = vertebraNames(k+1);
            end
        end

        % Get disc file path location
        discLevelsRepoPath = fullfile(discPath, subjName);
        discLevelsPath = fullfile(discLevelsRepoPath, discNames + ".stl");

        % -------------------------------------------------------
        % Construct per-subject struct
        % -------------------------------------------------------
        discData(i).discs.subjName = subjName;

        discData(i).discs.levelNames = discNames';
        discData(i).discs.levelPaths = discLevelsPath';

        discData(i).discs.supVertNames = supVertNames';
        discData(i).discs.infVertNames = infVertNames';

        discData(i).discs.numLevels = numel(discNames);
    end
end

