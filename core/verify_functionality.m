%% Description
% This script verifies the output of the new  plot boxplot for the feature_table based on factors.
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
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX

%% 
disp('--- Verifying the MEPFeatureExtraction toolbox ...')

config = make_config(dir_root);
dataRef_list = dir([config.path_dataRef, '*.mat']);
onset_table = readtable([config.path_dataRef, 'latency_threshold.xlsx'], 'ReadRowNames',true);
file_info = readtable([config.path_dataRef, 'file_info.xlsx']);
metadata = readtable([config.path_dataRef, 'metadata.xlsx']);
 %%
for k = 1:length(dataRef_list)
    disp(repmat('=', 1, 100))
    file_name = dataRef_list(k).name;
    disp(file_name)

    cur_file_info_index = contains(file_info.MEPs, file_name);
    cur_ID = file_info.ID{cur_file_info_index};
    cur_session = file_info.Session(cur_file_info_index);
    cur_hemis = file_info.Hemis{cur_file_info_index};

    % load metadata of the session
    cur_metadata = metadata(contains(metadata.ID, cur_ID),:);
    
    % base on metadata to get threshold value
    config.thresholds = get_threshold_value(onset_table, cur_metadata.AgeGroup, cur_metadata.Muscle, config.fs);

    extract_features(config, file_name)
end

%%
features_ref_list = struct2table(dir([config.path_featureRef, '*_features.mat']));
features_new_list = struct2table(dir([config.path_features, '*_features.mat']));

total_difference = NaN(height(features_new_list), 1);
for k = 1: height(features_new_list)
    cur_feature_set = features_new_list.name{k};
    disp(cur_feature_set)
    features_new = load([config.path_features cur_feature_set], "all_ft");
    features_new = features_new.all_ft;

    features_ref_file = features_ref_list.name{contains(features_ref_list.name, cur_feature_set)};
    features_ref = load([config.path_features features_ref_file], "all_ft");
    features_ref = features_ref.all_ft;
    
    total_difference(k) = sum(features_new - features_ref, "all", 'omitnan');
    disp(['===> Difference in feature value: ' num2str(total_difference(k))])
end

td = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
if exp(sum(total_difference)) == 1
    disp('-v- The total difference of the new feature sets to the reference is near zero.')
    disp(['-v- Package functions got verified at ' td])
else
    disp('-x- The new feature sets are different from the reference set.')
    disp('-x- Package functions are not verified.')
end