function config = make_config(dir_root)
%% Description
% This function creates a variable for configuration file (config) that
% specifies the default configuration options for the script.
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%% Define and create new directories
config.dir_root = dir_root;
config.path_data = [dir_root 'data\'];

td = char(datetime('today', 'Format', 'yyyyMMdd'));
% td = '20230413';
dirAnalysis        = [dir_root 'analysis_' td '\'];
config.path_figures   = [dirAnalysis 'figures\'];
config.path_features = [dirAnalysis 'features\'];
config.path_stat       = [dirAnalysis  'stat\'];
config.path_log       = [dirAnalysis  'logs\'];
config.path_analysis       = dirAnalysis ;

fields = fieldnames(config);
for k = 1: length(fields)
    if ~exist(config.(fields{k}),'dir')
        mkdir(config.(fields{k}))
    end
end

%% Define directories for evaluation
config.path_ref = [dir_root 'reference\'];
config.path_dataRef = [dir_root 'reference\data\'];
config.path_featureRef = [dir_root 'reference\analysis\features\'];
%% Locate the specific metadata files 
config.latency_threshold = [dir_root 'data\latency_threshold.xlsx'];
config.file_info = [dir_root 'data\file_info.xlsx'];
config.metadata = [dir_root 'data\metadata.xlsx'];
%% Configure the  
config.plotIt = 0;
config.runParallel = 1;

config.fs = 3; % sampling frequency in kHz

config.features = ["Amplitude", "Latency", "AUC", "Thickness", ...
    "nTurns", "nPhases", "Duration", "T1T", "T1A", "T2T", "T2A", ...
    "timeDiff", "ampRatio"];
config.feature_units = ["\muV", "ms", "", "", "turns", "phases", ...
    "ms", "ms", "\muV", "ms", "\muV", "ms", ""];

%% set plotting properties
plotOpt.figure_size = [600, 450]; % width and height of the figure in pixels
plotOpt.color_MEP_individual = [0.2 0.2 0.2]; % RGB triplet for individual MEPs in the main plot
plotOpt.color_MEP_mean = [1 0 0]; % RGB triplet for the MEP mean in the main plot
plotOpt.CI_bounds = 0.95; % confidence intervals of MEPs
plotOpt.alpha = 0.3; % area shading level for confidence intervals 

config.plotOpt = plotOpt;
