%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% File: analyzeBMD.m
% Author: Yousuf Abubakr
% Project: Morphologies
%
% Description:
%   Processes the BMD mean measurements CSV and runs level-wise Mann-Whitney
%   U tests (with Bonferroni, Holm, and BH corrections) on mean BMD values
%   per spinal level, consistent with the rest of summarizeData.m.
%
%   This script is designed to be run as a block inside or after
%   summarizeData.m, where cfg is already in the workspace.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Processing BMD measurements ...\n');

%% LOAD AND BUILD BMD TABLE
bmdCSVPath = fullfile(cfg.paths.data, 'bmd-mean-measurements.csv');
Tbmd       = buildBMDTable(bmdCSVPath);

fprintf('  Loaded %d observations across %d levels.\n', ...
    height(Tbmd), numel(unique(Tbmd.LevelName)));

%% LEVEL-WISE STATISTICS
% Running all three correction methods in parallel for comparison.
% levelRange from cfg controls which spinal levels are included,
% consistent with the other measurement analyses.

levelRange = cfg.summary.levelsExported;

% ---- Bonferroni (FWER) ----
optsBonf.multComp = 'bonferroni';
optsBonf.alpha    = 0.05;
[TbmdBonf, statsBonf] = levelwiseTests( ...
    Tbmd, 'vertebra', levelRange, 'BMD', optsBonf);

% ---- Holm step-down (FWER) ----
optsHolm.multComp = 'holm';
optsHolm.alpha    = 0.05;
[TbmdHolm, statsHolm] = levelwiseTests( ...
    Tbmd, 'vertebra', levelRange, 'BMD', optsHolm);

% ---- Benjamini-Hochberg (FDR) ----
optsBH.multComp = 'bh';
optsBH.q        = 0.05;
[TbmdBH, statsBH] = levelwiseTests( ...
    Tbmd, 'vertebra', levelRange, 'BMD', optsBH);

%% DISPLAY SUMMARY
fprintf('\n--- BMD Level-wise Results (Bonferroni) ---\n');
disp(TbmdBonf(:, {'Level','MedianC','MedianK','MedianDiff','pValue','pBonf','Signif_adj'}));

fprintf('\n--- BMD Level-wise Results (Holm) ---\n');
disp(TbmdHolm(:, {'Level','MedianC','MedianK','MedianDiff','pValue','pHolm','Signif_adj'}));

fprintf('\n--- BMD Level-wise Results (BH) ---\n');
disp(TbmdBH(:, {'Level','MedianC','MedianK','MedianDiff','pValue','qBH','Signif_adj'}));

%% PRINT SUMMARY STATISTICS
% Relative differences between groups:
relDiff = (TbmdBonf.MedianC - TbmdBonf.MedianK) ./ TbmdBonf.MedianC * 100;
relDiff = relDiff(~isnan(relDiff));

fprintf('\nKyphotic BMD are lower than control BMD by %.1f%% - %.1f%% across levels.\n', ...
    min(relDiff), max(relDiff));

% Levels significant under each method:
sigBonf = TbmdBonf.Level(TbmdBonf.Signif_adj == 1);
sigHolm = TbmdHolm.Level(TbmdHolm.Signif_adj == 1);
sigBH   = TbmdBH.Level(TbmdBH.Signif_adj == 1);

fprintf('Significant levels (Bonferroni, alpha=%.2f): %s\n', ...
    optsBonf.alpha, strjoin(sigBonf, ', '));
fprintf('Significant levels (Holm,        alpha=%.2f): %s\n', ...
    optsHolm.alpha, strjoin(sigHolm, ', '));
fprintf('Significant levels (BH,          q=%.2f):    %s\n', ...
    optsBH.q, strjoin(sigBH, ', '));

%% VISUALIZATION
plotLevelwiseStats( ...
    TbmdBH, 'vertebra', ...
    'YLabel', 'Mean BMD (mg/cm^{3})', ...
    'Title',  'Vertebral BMD by Level (BH correction)');

