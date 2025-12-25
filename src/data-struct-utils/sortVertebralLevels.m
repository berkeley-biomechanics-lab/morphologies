function [sorted, idx] = sortVertebralLevels(levels)
% sorting the string array of vertebral levels in 'levels' into 'sorted',
% which is another string array that is a natural, phenomelogical
% re-ordering of 'levels' (thoracic first, then lumbar)
%
% returns sorted string array 'sorted' and its corresponding indexing array
% 'idx'

    % Extract prefix (T or L)
    region = extractBefore(levels, 2); 

    % Extract numeric part
    nums = double(extractAfter(levels, 1)); 

    % Convert region to group priority
    group = zeros(size(region));
    group(region == "T") = 1;
    group(region == "L") = 2;

    % Compute sorting order
    [~, idx] = sortrows([group(:), nums(:)], [1 2]);

    % Apply sorting
    sorted = levels(idx);
end

