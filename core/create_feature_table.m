%% Description
% This script combines all the files in analysis_xxxxxx/features folders
% into a table and save it for further analysis.
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%%
features_list = dir([config.path_features, '*_features.mat']);
file_info = readtable(config.file_info);
metadata = readtable(config.metadata);

features_table = table;
for k = 1:length(features_list)
    cur_feature_file = features_list(k).name;
    load([config.path_features cur_feature_file], "all_ft", "isWrong")

    file_name = replace(cur_feature_file, '_features.mat', '');
    
    % mapping to the correct file information
    cur_file_info_index = contains(file_info.MEPs, file_name);
    cur_ID = file_info.ID{cur_file_info_index};
    cur_session = file_info.Session(cur_file_info_index);
    cur_hemis = file_info.Hemis{cur_file_info_index};

    % load metadata of the session
    cur_metadata = metadata(contains(metadata.ID, cur_ID),:);
    cur_table = repmat(cur_metadata, size(all_ft,1), 1);
    % create metadata columns
    cur_table.ID = repmat(cur_ID, size(all_ft,1), 1);
    cur_table.Session = repmat(cur_session, size(all_ft,1), 1);
    cur_table.Hemis = repmat(cur_hemis, size(all_ft,1), 1);

    cur_table = [cur_table array2table(all_ft, "VariableNames", config.features)];
    features_table = [features_table; cur_table];
end

%%
invalid_amp = find(isnan(features_table.Amplitude) | features_table.Amplitude==0);
features_table.Amplitude(invalid_amp) = 0;
features_table.Latency(invalid_amp) = NaN;
features_table.AUC(invalid_amp) = 0;
features_table.Thickness(invalid_amp) = NaN;
features_table.nTurns(invalid_amp) = NaN;
features_table.nPhases(invalid_amp) = NaN;
features_table.Duration(invalid_amp) = NaN;
features_table.T1T(invalid_amp) = NaN;
features_table.T1A(invalid_amp) = 0;
features_table.T2T(invalid_amp) = NaN;
features_table.T2A(invalid_amp) = 0;
features_table.timeDiff(invalid_amp) = NaN;
features_table.ampRatio(invalid_amp) = NaN;

writetable(features_table, [config.path_stat 'features_table.xlsx'])

disp(['Feature table is created and save to ' config.path_stat])

missed_trials = sum(features_table.Amplitude == 0 | isnan(features_table.Amplitude));
fprintf('Percent of missed trials: %d/%d = %.2f%% \n', ...
    missed_trials, height(features_table), missed_trials/height(features_table)*100)
