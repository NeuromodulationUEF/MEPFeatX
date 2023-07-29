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
ref_data_list = dir([config.path_dataRef, '*.mat']);
onset_threshold = readtable([config.path_dataRef, 'onset_threshold.xlsx'], 'ReadRowNames',true);
metadata = readtable([config.path_dataRef, 'metadata_table.xlsx']);
%%
for k = 1:length(ref_data_list)
    disp(repmat('=', 1, 100))
    file_name = ref_data_list(k).name;
    disp(file_name)
    
    % load metadata of the session
    cur_metadata = metadata(contains(metadata.MEPs, file_name),:);
    
    % base on metadata to get threshold value
    config = get_threshold_value(onset_threshold, ...
        cur_metadata.AgeGroup, cur_metadata.Muscle, config);
    extract_features(config, file_name)
end

%%
ref_ft_list = struct2table(dir([config.path_featureRef, '*_features.csv']));
new_ft_list = struct2table(dir([config.path_features, '*_features.csv']));

total_difference = NaN(height(new_ft_list), 1);
for k = 1: height(new_ft_list)
    cur_feature_file = new_ft_list.name{k};
    disp(cur_feature_file)
    new_ft = readtable([config.path_features cur_feature_file]);
    
    if contains(cur_feature_file, 'ID07')
        % ID07 is used for testing only
        total_difference(k) = 0;
        continue
    end
    ref_ft_file = ref_ft_list.name{contains(ref_ft_list.name, cur_feature_file)};
    ref_ft = readtable([config.path_features ref_ft_file]);
    
    total_difference(k) = sum(abs(table2array(new_ft) - table2array(ref_ft)), "all", 'omitnan');
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

for k = 1: height(new_ft_list)
    delete([new_ft_list.folder{k}, '\', new_ft_list.name{k}])
end
clear cur* ref* new* total_difference k file_name metadata onset_table