function extract_features_RC(config, file_name)
%% Description
% extract_features and extract_features_x functions extract MEP features
% from the input dataset. It first visualizes the whole dataset, and then
% extracts features, visualizes and saves figures to analysis_xxxxxx
% folder.
%
% Inputs:
%   config:     config file for controlling the feature extraction
%   file_name:  MEP dataset either in MAT-file or ASCII file.
%
% Output: All outputs of this function are saved to analysis_xxxxxx folder.
%   features:   saved in MAT-files under the 'features/' subfolder, and
%   figures:    saved in .png under 'figures/[file_name]' subfolders
%
% Notes:
%   (1) This function create new directories to save outputs based on the
%   file_name. Edit the var 'sequence_name' according to the desired
%   naming.
%
%   (2) MEP dataset should have rows as samples, and column as a
%   stack of trials.
%
%   (3) The length of time (t) must be equal to the number of samples in
%   response. If not, either re-config (t) in configuration, or prepare MEP
%   dataset to desired length.
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%% Load the mep file
if ~exist([config.path_data file_name], 'file')
    disp(['Could not find or open ' config.path_data file_name])
    return
end

vars_in_file = who('-file', [config.path_data file_name]);
if ismember("raw_meps", vars_in_file)
    load([config.path_data file_name], "meps", "raw_meps", "SI")
else
    load([config.path_data file_name], "meps", "SI")
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
    hold on
    plot(t, meps, 'Color', plotOpt.color_MEP_individual)

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
all_ft = extract_feature_all(meps, raw_meps, config);

T = array2table(all_ft, 'VariableNames', config.features);
T.SI = SI;
writetable(T, [config.path_features sequence_name '_features.csv'])

if config.plotIt
    save_figures(path_figure_current, config.runParallel)
end
