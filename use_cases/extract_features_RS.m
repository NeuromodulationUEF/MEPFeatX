function extract_features_RS(config, file_name)
%% Description 
% extract_features_RS is the modified extract_features.m for repetition
% supression dataset. The sample dataset contains 20 bursts, each has four
% pulses at 120% rMT delivered 1 s apart.  The script first groups and
% visualizes the first pulses and the second pulses, then extracts and
% visualizes features. The features and figures then are saved to
% analysis_xxxxxx folder.
%
% Notes:
%   1. Pulse order and pulse group should be edited according to the
%   stimulation protocol. 
%   2. In analysis of RS sequences and pair-pulse TMS, such as LICI, if the
%   first pulse is failed to elicit any response, the whole group must be
%   discarded.
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%% Load the mep file
if ~exist([config.path_data file_name], 'file')
    disp(['Could not find or open ' config.path_data file_name])
    return
end

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
pulse_order = repmat(1:4, 1, 20)';
pulse_group = repmat(1:20, 4, 1);
pulse_group = pulse_group(:);

%% Plot LICI responses separated by the pulse order
sequence_name = replace(file_name, '.mat', '');

if config.plotIt
    % Create a folder for this dataset in analysis/figures/
    path_figure_current = [config.path_figures sequence_name '\'];
    if ~exist(path_figure_current, "dir")
        mkdir(path_figure_current)
    end

    nn = length(t);

    plotOpt = config.plotOpt;
    figure('Name', sequence_name, 'Position', [0 0 plotOpt.figure_size]);

    hold on;
    for k = 1:5
        plot3(ones(nn, 1)*k, t, meps(:, pulse_order==k), 'Color', plotOpt.color_MEP_individual)

        meps_CIs = calculate_CIs(meps(:, pulse_order==k), plotOpt.CI_bounds);
        fill3(ones(nn*2, 1)*k, [t fliplr(t)], [meps_CIs(:,1)', fliplr(meps_CIs(:,2)')], ...
            plotOpt.color_MEP_mean, ...
            'Facecolor', plotOpt.color_MEP_mean, ...
            'Facealpha', plotOpt.alpha, ...
            'Edgecolor', plotOpt.color_MEP_mean);

        plot3(ones(nn, 1)*k, t, mean(meps(:, pulse_order==k), 2, "omitnan"), 'Color', plotOpt.color_MEP_mean, 'LineWidth', 1.5)
    end

    if any(pulse_order>4)
        plot3(ones(nn, 1)*5, t, meps(:, pulse_order > 4), 'Color', plotOpt.color_MEP_individual)
        plot3(ones(nn, 1)*5, t, mean(meps(:, pulse_order > 4), 2, "omitnan"), 'Color', plotOpt.color_MEP_mean, 'LineWidth', 1.5)
    end
    hold off

    view(50, 10);
    grid minor
    xlabel('Pulse order'); ylabel('Time (ms)'); zlabel('MEP Amplitude (\muV)');

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
