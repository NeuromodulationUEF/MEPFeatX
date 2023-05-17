function extract_features_SICF(config, file_name)
%% Description
% extract_features_SICF is the modified extract_features.m for
% short-interval cortical facilitation sequences. There are three sample
% SICF datasets. Each contains 20 bursts, each has two pulses at delivered
% 1.4-7.0 ms apart. The script first groups and visualizes the first pulses
% and the second pulses, then extracts and visualizes features. The
% features and figures then are saved to analysis_xxxxxx folder.
%
% Inputs:
%   config:     config file for controlling the feature extraction
%   file_name:  MEP dataset either in MAT-file or ASCII file.
%
% Output: All outputs of this function are saved to analysis_xxxxxx folder.
%   features:   saved in MAT-files under the 'features/' subfolder, and
%   figures:    saved in .png under 'figures/[file_name]' subfolders
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

%% Plot the whole dataset and its mean
sequence_name = replace(file_name, '.mat', '');

if config.plotIt
    path_figure_current = [config.path_figures sequence_name '\'];
    if ~exist(path_figure_current, "dir")
        mkdir(path_figure_current)
    end
    plotOpt = config.plotOpt;
    
    figure('Name', sequence_name, 'Position', [0 0 plotOpt.figure_size]);
    % remove response that contains some queer noise around 5 ms (it
    % happens in SICF sequences.
    artifact_5ms = max(abs(meps(t > 0 & t < 12, :))) > 200;
    hold on
    plot(t, meps(:, ~artifact_5ms), 'Color', plotOpt.color_MEP_individual)
    if any(artifact_5ms)
        plot(t, meps(:, artifact_5ms), 'Color', plotOpt.color_MEP_individual, 'LineStyle', ':')
    end

    meps(:, artifact_5ms) = zeros(size(meps(:, artifact_5ms)));
    meps_CIs = calculate_CIs(meps, plotOpt.CI_bounds);

    fill([t fliplr(t)], [meps_CIs(:,1)', fliplr(meps_CIs(:,2)')], ...
        plotOpt.color_MEP_mean, ...
        'Facecolor', plotOpt.color_MEP_mean, ...
        'Facealpha', plotOpt.alpha, ...
        'Edgecolor', plotOpt.color_MEP_mean);
    plot(t, mean(meps, 2), 'Color', plotOpt.color_MEP_mean, 'LineWidth', 1.5)
    
    hold off

    title('Main plot')
    axis ij; grid minor
    xlabel('Time (ms)'); ylabel('MEP Amplitude (\muV)')
    
    print(gcf, '-r600', '-dpng', [path_figure_current 'main_plot.png']);
    close all
end

%% Extract features
[all_ft, all_turns, isWrong] = extract_feature_all(meps, raw_meps, config);

save([config.path_features sequence_name '_features.mat'], ...
    'all_ft', 'all_turns', "isWrong")

if config.plotIt
    save_figures(path_figure_current, config.runParallel)
end
