function [meanBegin, meanEnd, idxBegin, idxEnd] = edgeMeans(x, rl, ru)
% Compute means over beginning and end percentage ranges
%
% x      : data vector (n x 1 or 1 x n)
% APrl   : lower fraction (e.g., 0.05)
% APru   : upper fraction (e.g., 0.15)

    x = x(:);            % ensure column vector
    n = numel(x);

    % Convert fractions to indices
    iL = max(1, round(rl * n));
    iU = min(n, round(ru * n));

    % Beginning segment (anterior/left region)
    idxBegin = iL:iU;

    % End segment (posterior/right region)
    idxEnd = (n - iU + 1):(n - iL + 1);

    % Mean (ignore NaNs if present)
    meanBegin  = mean(x(idxBegin), 'omitnan');
    meanEnd = mean(x(idxEnd), 'omitnan');
end

