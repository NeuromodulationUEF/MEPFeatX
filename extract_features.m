function extract_features(config, file_name)
%% Description
% This function extracts MEP features from the input dataset.
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
    load([config.path_data file_name], "meps", "raw_meps")
else
    load([config.path_data file_name], "meps")
    raw_meps = NaN(size(meps));
end

%% Check if time vector and meps have equal number of samples
t = config.thresholds.t;

if length(t) ~= size(meps, 1)
    disp('Unmatched number of samples in response and configured time samples.')
    return
end

%% Extract features
sequence_name = replace(file_name, '.mat', '');
all_ft = extract_feature_all(meps, raw_meps, config);

T = array2table(all_ft, 'VariableNames', config.features);
writetable(T, [config.path_features sequence_name '_features.csv'])

if config.plotIt
    path_figure_current = [config.path_figures sequence_name '\'];
    if ~exist(path_figure_current, "dir")
        mkdir(path_figure_current)
    end
    
    save_figures(path_figure_current, config.runParallel)
end
