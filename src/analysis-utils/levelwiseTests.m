function [Tout, stats] = levelwiseTests(T, structure, levelRange, yvar, opts)
% Perform level-wise Mann-Whitney U tests from a summary table.
%
% Inputs
% ------
% T         : table with variables:
%             - LevelName (string/categorical)
%             - Group ('control' or 'kyphotic')
%             - (yvar) (numeric)
% structure : 'vertebra' or 'disc'
% levelRange: string array like ["T1","L6"]
% yvar      : name of the response variable in T (e.g. 'Volume')
% opts      : (optional) struct with fields:
%
%   opts.multComp  (default: 'bonferroni')
%       'bonferroni' - FWER control; multiply each p-value by m
%       'holm'       - FWER control (step-down); uniformly more powerful
%                      than Bonferroni while still controlling FWER
%       'bh'         - FDR control (Benjamini-Hochberg); controls expected
%                      proportion of false discoveries, not FWER
%
%   opts.alpha  (default: 0.05)
%       Level at which the FWER is controlled.
%       Used by 'bonferroni' and 'holm' only.
%       Interpretation: probability of making >= 1 false rejection
%       across all m tests is at most alpha.
%
%   opts.q  (default: 0.05)
%       Level at which the FDR is controlled.
%       Used by 'bh' only. Conceptually distinct from alpha:
%       q is the tolerated expected proportion of false discoveries
%       among all rejected hypotheses, not a probability of any
%       single false rejection.
%
% Outputs
% -------
% Tout  : table with level-wise statistics and adjusted values
% stats : struct with raw p, adjusted values, and metadata

    % -------------------------
    % Defaults
    % -------------------------
    if nargin < 5, opts = struct(); end
    if ~isfield(opts, 'multComp'), opts.multComp = 'bonferroni'; end
    if ~isfield(opts, 'alpha'),    opts.alpha    = 0.05;         end
    if ~isfield(opts, 'q'),        opts.q        = 0.05;         end

    % Determine the rejection threshold label and value based on method:
    % FWER methods use opts.alpha; FDR method uses opts.q.
    switch lower(opts.multComp)
        case {'bonferroni', 'holm'}
            rejThresh      = opts.alpha;
            rejThreshLabel = sprintf('alpha = %.3f (FWER)', opts.alpha);
        case 'bh'
            rejThresh      = opts.q;
            rejThreshLabel = sprintf('q = %.3f (FDR)', opts.q);
        otherwise
            error("levelwiseTests: unknown multComp '%s'. " + ...
                  "Choose 'bonferroni', 'holm', or 'bh'.", opts.multComp);
    end

    % -----------------------------
    % Resolve valid levels
    % -----------------------------
    levels = resolveLevels(structure, levelRange);
    nL     = numel(levels);

    isValidLevel = ismember(T.LevelName, levels);
    T = T(isValidLevel, :);

    % -------------------------
    % Preallocate
    % -------------------------
    medC  = nan(nL,1); q1C = nan(nL,1); q3C = nan(nL,1);
    medK  = nan(nL,1); q1K = nan(nL,1); q3K = nan(nL,1);
    pRaw  = nan(nL,1);
    nC    = nan(nL,1); nK  = nan(nL,1);

    % -------------------------
    % Level-wise Mann-Whitney U tests
    % -------------------------
    for i = 1:nL
        lvl = levels(i);

        xc = T.(yvar)(T.LevelName == lvl & T.Group == 'control');
        xk = T.(yvar)(T.LevelName == lvl & T.Group == 'kyphotic');

        xc = xc(~isnan(xc));
        xk = xk(~isnan(xk));

        nC(i) = numel(xc);
        nK(i) = numel(xk);

        if nC(i) < 2 || nK(i) < 2
            continue
        end

        medC(i) = median(xc);  q1C(i) = prctile(xc,25);  q3C(i) = prctile(xc,75);
        medK(i) = median(xk);  q1K(i) = prctile(xk,25);  q3K(i) = prctile(xk,75);

        pRaw(i) = ranksum(xc, xk);
    end

    % -------------------------
    % Multiple-comparison correction
    % -------------------------
    validMask = ~isnan(pRaw);
    m         = sum(validMask);
    pValid    = pRaw(validMask);

    adjAll = nan(nL, 1);

    switch lower(opts.multComp)

        case 'bonferroni'
            % FWER control: P(>= 1 false rejection) <= alpha.
            % Multiply each p-value by m; cap at 1.
            adjValid = min(pValid * m, 1);
            adjLabel = 'pBonf';
            adjDesc  = sprintf('Bonferroni (FWER, alpha=%.3f)', opts.alpha);

        case 'holm'
            % FWER control (step-down): P(>= 1 false rejection) <= alpha.
            % Per Algorithm 13.1: sort p ascending, compare p_(j) to
            % alpha/(m+1-j). Uniformly more powerful than Bonferroni.
            % Implemented here as adjusted p-values for table display:
            % adj_p_(j) = min(p_(j) * (m+1-j), 1), then running max
            % to enforce monotonicity.
            [pSorted, sortIdx] = sort(pValid);
            adjSorted          = zeros(m, 1);

            for k = 1:m
                adjSorted(k) = min(pSorted(k) * (m + 1 - k), 1);
            end

            % Step-down monotonicity: each adjusted p >= the previous:
            adjSorted = cummax(adjSorted);

            adjValid          = zeros(m, 1);
            adjValid(sortIdx) = adjSorted;
            adjLabel          = 'pHolm';
            adjDesc           = sprintf('Holm step-down (FWER, alpha=%.3f)', opts.alpha);

        case 'bh'
            % FDR control (Benjamini-Hochberg): E[V/R] <= q.
            % Per Algorithm 13.2: sort p ascending, find largest j such
            % that p_(j) < q*j/m, reject H_01 through H_0L.
            % Expressed here as adjusted q-values for table display.
            % NOTE: the rejection threshold is opts.q, NOT opts.alpha.
            adjValid = fdrBH(pValid);
            adjLabel = 'qBH';
            adjDesc  = sprintf('Benjamini-Hochberg (FDR, q=%.3f)', opts.q);
    end

    adjAll(validMask) = adjValid;

    % -------------------------
    % Rejection decisions
    % -------------------------
    % FWER methods: reject if adjusted p-value < alpha
    % FDR method:   reject if adjusted q-value < q
    sigRaw = pRaw   < opts.alpha;   % unadjusted (always uses alpha)
    sigAdj = adjAll < rejThresh;    % adjusted (uses alpha or q as appropriate)

    % -------------------------
    % Build output table
    % -------------------------
    Tout = table( ...
        levels(:), ...
        medC, q1C, q3C, ...
        medK, q1K, q3K, ...
        medC - medK, ...
        nC, nK, ...
        pRaw, adjAll, ...
        sigRaw, sigAdj, ...
        'VariableNames', { ...
            'Level', ...
            'MedianC', 'Q1C', 'Q3C', ...
            'MedianK', 'Q1K', 'Q3K', ...
            'MedianDiff', ...
            'numControl', 'numKyphotic', ...
            'pValue', adjLabel, ...
            'Signif_p', 'Signif_adj'});

    % -------------------------
    % Stats struct
    % -------------------------
    stats.structure      = structure;
    stats.levels         = levels;
    stats.multComp       = opts.multComp;
    stats.alpha          = opts.alpha;
    stats.q              = opts.q;
    stats.rejThresh      = rejThresh;
    stats.rejThreshLabel = rejThreshLabel;
    stats.m              = m;
    stats.pRaw           = pRaw;
    stats.pAdj           = adjAll;
    stats.adjLabel       = adjLabel;
    stats.method         = sprintf( ...
        'Level-wise Mann-Whitney U tests (%d valid tests), %s', ...
        m, adjDesc);
    stats.table          = Tout;

    fprintf('%s\n', stats.method);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL: cummax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = cummax(x)
% Running maximum (for Holm step-down monotonicity enforcement).
    y = x;
    for i = 2:numel(x)
        y(i) = max(y(i), y(i-1));
    end
end

