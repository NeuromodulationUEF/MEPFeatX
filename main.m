%% Description on MEPFeatX package
% MEPFeatX provides scripts and templates to extract features from
% motor-evoked potentials in transcranial magnetic stimulation, and
% visualizes these signals for evaluation.
%
% Scientific articles:
%   (1) D. T. A. Nguyen, S. M. Rissanen, P. Julkunen, E. Kallioniemi, and
%   P. A. Karjalainen, Principal Component Regression on Motor Evoked
%   Potential in Single-Pulse Transcranial Magnetic Stimulation, IEEE
%   Transactions on Neural Systems and Rehabilitation Engineering, vol. 27,
%   no. 8. pp. 1521-1528, 2019. doi:
%   https://doi.org/10.1109/TNSRE.2019.2923724.
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%% Description on main.m
% main.m itself:
%   (1) verifies the package's functions before the first use 
%   (2) runs on all use cases, which performs the feature extraction on
%   seven stimulation paradigms.
%
%% create configuration var
close all;
clear 

% Define working folder
dir_root = 'D:\MEPanalyzer\';
cd(dir_root)
addpath([dir_root 'core\'])
addpath([dir_root 'use_cases\'])

% Create configuration var
time_now = char(datetime('now', 'Format', 'yyyyMMdd_HHmmSS'));
config = make_config(dir_root);

%% Verify the toolbox before the first use
disp(repmat('=', 1, 100))
diary([config.path_ref 'verifying_MEPFeatX_' time_now '.txt'])
verify_functionality
diary off

%% Run one dataset
% config = make_config(dir_root);
% config.plotIt = 1;
% 
% % mapping to the correct file information
% cur_file_info_index = contains(file_info.MEPs, file_name);
% cur_ID = file_info.ID{cur_file_info_index};
% cur_session = file_info.Session(cur_file_info_index);
% cur_hemis = file_info.Hemis{cur_file_info_index};
% 
% % load metadata of the session
% cur_metadata = metadata(contains(metadata.ID, cur_ID),:);
% 
% % base on metadata to get threshold value
% config.thresholds = get_threshold_value(onset_table, cur_metadata.AgeGroup, cur_metadata.Muscle, config.fs);
% 
% file_name = 'ID10_2.mat';
% extract_features(config, file_name)

%% Run all use cases

% Comment if not plotting figures
% config.plotIt = 1;

% List all response .mat files in data path
resp_list = struct2table(dir([config.path_data '*.mat']));
onset_table = readtable(config.latency_threshold, 'ReadRowNames',true);
file_info = readtable(config.file_info);
metadata = readtable(config.metadata);

diary([config.path_log 'MEPFeatX_CO_analysis_' time_now '.txt'])
tic
% for k = 1:height(resp_list)
parfor k = 1:height(resp_list)
    config = make_config(dir_root);
    config.plotIt = 1;

    disp(repmat('=', 1, 100))
    file_name = resp_list.name{k};
    disp(file_name)
    
    % mapping to the correct file information
    cur_file_info_index = contains(file_info.MEPs, file_name);
    cur_ID = file_info.ID{cur_file_info_index};
    cur_session = file_info.Session(cur_file_info_index);
    cur_hemis = file_info.Hemis{cur_file_info_index};

    % load metadata of the session
    cur_metadata = metadata(contains(metadata.ID, cur_ID),:);
    
    % base on metadata to get threshold value
    config.thresholds = get_threshold_value(onset_table, cur_metadata.AgeGroup, cur_metadata.Muscle, config.fs);

    % Run feature extraction on LICI, RS, and single-pulse sequence. Here
    % we have LICI and RS are plotted according to pulse order in each
    % burst.

    if contains(cur_metadata.Protocol, "LICI")
        extract_features_LICI(config, file_name)
    elseif contains(cur_metadata.Protocol, "RS")
        extract_features_RS(config, file_name)
    elseif contains(cur_metadata.Protocol, "SICF")
        extract_features_SICF(config, file_name)    
    elseif contains(cur_metadata.Protocol, "120% rMT")
        extract_features_singlePulse(config, file_name)
    else
        extract_features(config, file_name)
    end
end

%% Create feature table for further analysis
disp(repmat('=', 1, 100))
disp('Create a table for MEP features')
create_feature_table

disp('Plot feature boxplots')
plot_feature_boxplots(config, 'Session')
plot_feature_boxplots(config, 'Muscle')
plot_feature_boxplots(config, 'SequenceType')

%% Example of plotting boxplots for each features
disp(repmat('=', 1, 100))
toc
diary off


