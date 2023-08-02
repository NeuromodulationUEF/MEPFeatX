function create_feature_table(config)
%% Description
% This script combines all the files in analysis_xxxxxx/features folders
% into a table and save it for further analysis.
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX

%%
features_list = struct2table(dir([config.path_features, '*_features.csv']));
metadata = readtable(config.metadata);

features_table = table;
metadata2 = metadata;

for k = 1:height(features_list)
    cur_feature_file = features_list.name{k};
    all_ft = readtable([config.path_features cur_feature_file]);
    
    if ~contains("PulseOrder", all_ft.Properties.VariableNames)
        all_ft.PulseOrder = zeros(height(all_ft), 1);
        all_ft.PulseGroup = zeros(height(all_ft), 1);
    end 
    
    if ~contains("SI", all_ft.Properties.VariableNames)
        all_ft.SI = 120*ones(height(all_ft), 1);
    end 
    
    file_name = replace(cur_feature_file, '_features.csv', '');
    isWrong = find(isnan(all_ft.Amplitude) | all_ft.Amplitude==0);
       
    % load metadata of the session
    cur_metadata = metadata(contains(metadata.MEPs, file_name),:);
    metadata2.Excluded{contains(metadata.MEPs, file_name)} = sprintf('%i,', isWrong);

    cur_table = [repmat(cur_metadata, height(all_ft), 1), all_ft];
       
    features_table = [features_table; cur_table];
end
features_table = movevars(features_table, ["SI", "PulseGroup", "PulseOrder"], 'Before', 'Amplitude');

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
writetable(metadata2, [config.path_stat 'metadata_updated.xlsx'])
disp(['Feature table is created and save to ' config.path_stat])
disp(['Metadata table is now updated with excluded MEPs: ' [config.path_stat 'metadata_updated.xlsx']])

missed_trials = sum(features_table.Amplitude == 0 | isnan(features_table.Amplitude));
fprintf('Percent of no-response trials: %d/%d = %.2f%% \n', ...
    missed_trials, height(features_table), missed_trials/height(features_table)*100)

