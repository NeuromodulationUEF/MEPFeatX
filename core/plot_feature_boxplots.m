function plot_feature_boxplots(config, factor)
%% Description
% plot_feature_boxplots plot boxplot for the feature_table based on factors.
%
% Inputs:
%   config:          configuration file
%   factor:         categories. Can be any metadata column.
%   iy:         preprocessed response
%
% Outputs: the boxplots are saved to "stat/" folder
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


close all
features_table = readtable([config.path_stat 'features_table.xlsx']);
features_table(features_table.Amplitude == 0 | isnan(features_table.Amplitude), :) = [];
features_list = config.features;
for k = 1:length(features_list)
    figure('Name', ['Boxplot_' features_list{k}]);
    cur_feature = features_table.(features_list{k});
    cur_feature(cur_feature==0) = NaN;
    boxplot(cur_feature, features_table.(factor))
    ylabel([features_list{k} ' (' config.feature_units{k} ')'])
    grid minor
    hold off
end

%% Saving figures
time_now = char(datetime('now', 'Format', 'yyyyMMdd'));
path_stat_boxplots = [config.path_stat 'feature_boxplots\' time_now '\' factor '\'];
save_figures(path_stat_boxplots, config.runParallel)