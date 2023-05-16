function extract_features_LICI(config, file_name)
% extract_features_LICI is the modified extract_features.m for
% long-interval cortical inhibition (LICI) sequences. This sample dataset
% contains 20 bursts, each has two pulses. The script first groups and
% visualizes the first pulses and the second pulses, then extracts and
% visualizes features. The features and figures then are saved to
% analysis_xxxxxx folder.
% 
% For more details on the extraction, check extract_features.m
%
% Notes:
%   1. Pulse order and pulse group should be edited according to the LICI
%   protocol if different
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%% Load the mep file
load([config.path_data file_name], "meps", "raw_meps")
if ~exist("raw_meps", "var")
    raw_meps = NaN(size(meps));
end

%% Check if time vector and meps have equal number of samples
t = config.thresholds.t;

if length(t) ~= size(meps, 1)
    disp('Unmatched number of samples in response and configured time.')
    return
end

%% Create pulse order in each burst, and burst group in LICI
pulse_order = repmat([1, 2], 1, 20);
pulse_group = repmat(1:20,2,1);
pulse_group = pulse_group(:);

%% Plot LICI responses separated by the pulse order
sequence_name = replace(file_name, '.mat', '');

if config.plotIt
    % Create a folder for this dataset in analysis/figures/
    path_figure_current = [config.path_figures sequence_name '\'];
    if ~exist(path_figure_current, "dir")
        mkdir(path_figure_current)
    end

    plotOpt = config.plotOpt;
    figure('Name', sequence_name, 'Position', [0 0 plotOpt.figure_size]);

    % Plot first pulses
    subplot(211); hold on
    plot(t, meps(:, pulse_order==1), 'Color', plotOpt.color_MEP_individual)

    meps_CIs = calculate_CIs(meps(:, pulse_order==1), plotOpt.CI_bounds);

    fill([t fliplr(t)], [meps_CIs(:,1)', fliplr(meps_CIs(:,2)')], ...
        plotOpt.color_MEP_mean, ...
        'Facecolor', plotOpt.color_MEP_mean, ...
        'Facealpha', plotOpt.alpha, ...
        'Edgecolor', plotOpt.color_MEP_mean);


    plot(t, mean(meps(:, pulse_order==1), 2, "omitnan"), 'Color', plotOpt.color_MEP_mean, 'LineWidth', 1.5)
    hold off

    title('First Pulse')
    axis ij; grid minor
    xlabel('Time (ms)'); ylabel('MEP Amplitude (\muV)')

    % Plot second pulses
    subplot(212); hold on;
    plot(t, meps(:, pulse_order==2), 'Color', plotOpt.color_MEP_individual)

    meps_CIs = calculate_CIs(meps(:, pulse_order==2), plotOpt.CI_bounds);
    fill([t fliplr(t)], [meps_CIs(:,1)', fliplr(meps_CIs(:,2)')], ...
        plotOpt.color_MEP_mean, ...
        'Facecolor', plotOpt.color_MEP_mean, ...
        'Facealpha', plotOpt.alpha, ...
        'Edgecolor', plotOpt.color_MEP_mean);

    plot(t, mean(meps(:, pulse_order==2), 2, "omitnan"), 'Color', plotOpt.color_MEP_mean, 'LineWidth', 1.5)
    hold off

    title('Second Pulse')
    axis ij; grid minor
    xlabel('Time (ms)'); ylabel('MEP Amplitude (\muV)')

    print(gcf, '-r600', '-dpng', [path_figure_current 'main_plot.png']);
    close all
end

%% Extract features
[all_ft, all_turns, isWrong] = extract_feature_all(meps, raw_meps, config);

save([config.path_features sequence_name '_features.mat'], ...
    'all_ft', 'all_turns', "isWrong", "pulse_group", "pulse_order")

if config.plotIt
    save_figures(path_figure_current, config.runParallel)
end
