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
dir_root = 'D:\MEPFeatX\';
cd(dir_root)
addpath([dir_root 'core\'])
addpath([dir_root 'use_cases\'])

%% Customize configuration parameters
time_now = char(datetime('now', 'Format', 'yyyyMMdd_HHmmSS'));
config = make_config(dir_root);

%% Verify the toolbox before the first use
disp(repmat('=', 1, 100))
diary([config.path_ref 'verifying_MEPFeatX_' time_now '.txt'])
verify_functionality
diary off

%% Load onset threshold table and metadata table
onset_table = readtable(config.latency_threshold, 'ReadRowNames',true);
metadata = readtable(config.metadata);

%% Run one dataset
% if 1, plot all MEP figures
config.plotIt = 1;

file_name = 'ID10_2.mat';
cur_metadata = metadata(contains(metadata.MEPs, file_name),:);

% base on metadata to get threshold value
config.thresholds = get_threshold_value(onset_table, cur_metadata.AgeGroup, cur_metadata.Muscle, config.fs);

extract_features(config, file_name)

%% Run all datasets listed in metadata table

diary([config.path_log 'MEPFeatX_CO_analysis_' time_now '.txt'])
tic

for k = 1:height(metadata)
% parfor k = 1:height(resp_list)
%     config = make_config(dir_root);
%     config.plotIt = 1;

    % load metadata of the dataset
    cur_metadata = metadata(k,:);

    disp(repmat('=', 1, 100))
    file_name = cur_metadata.MEPs{:};
    if isempty(file_name)
        disp('No available information on the current dataset')
        continue
    end

    disp(file_name)
      
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
    elseif contains(cur_metadata.Protocol, "Stimulus_response")
        extract_features_singlePulse(config, file_name)
    else
        extract_features(config, file_name)
    end
end

%% Create feature table for further analysis
disp(repmat('=', 1, 100))
disp('Create a table for MEP features')
create_feature_table

disp(repmat('=', 1, 100))
toc
diary off

%% Plot feature boxplots for each subcategory
disp('Plot feature boxplots')
plot_feature_boxplots(config, 'Session')
plot_feature_boxplots(config, 'Muscle')
plot_feature_boxplots(config, 'SequenceType')


