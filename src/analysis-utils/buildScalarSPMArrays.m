function [Y_control, Y_kyphotic, levelLabels] = ...
    buildScalarSPMArrays(T, varargin)
% Build SPM-ready scalar arrays (e.g. volume)
%
% OUTPUT
% ------
% Y_control   : [N_control  × Q]
% Y_kyphotic  : [N_kyphotic × Q]
% levelLabels : 1×Q string (ordered spinal levels)
%
% OPTIONS
% -------
% 'Structure'  : 'vertebra' | 'disc'
% 'LevelRange' : ["T12","L3"]

    % -----------------------------
    % Parse inputs
    % -----------------------------
    p = inputParser;
    addRequired(p,'T',@(x)istable(x));

    addParameter(p,'Structure','vertebra',@(x)ischar(x)||isstring(x));
    addParameter(p,'LevelRange',["T12","L3"],@(x)isstring(x)&&numel(x)==2);

    parse(p,T,varargin{:});
    opt = p.Results;

    % -----------------------------
    % Filter by structure
    % -----------------------------
    T = T(T.Structure == opt.Structure,:);

    % -----------------------------
    % Resolve levels
    % -----------------------------
    levelLabels = resolveLevels(opt.Structure, opt.LevelRange);

    % -----------------------------
    % Split groups
    % -----------------------------
    T_control  = T(T.isKyphotic == 0,:);
    T_kyphotic = T(T.isKyphotic == 1,:);

    % -----------------------------
    % Build arrays
    % -----------------------------
    Y_control  = buildGroupArray(T_control,  levelLabels);
    Y_kyphotic = buildGroupArray(T_kyphotic, levelLabels);
end

