%% Description on MEPFeatX package
% MEPFeatX provides scripts and templates to extract features from
% motor-evoked potentials in transcranial magnetic stimulation, and
% visualizes these signals for evaluation.
%
% Scientific articles:
%
%   (2) D. T. A. Nguyen et al., “Developmental models of motor-evoked
%   potential features by transcranial magnetic stimulation across age
%   groups from childhood to adulthood,” Scientific Reports 2023 13:1, vol.
%   13, no. 1, pp. 1–11, Jun. 2023, doi: 10.1038/s41598-023-37775-w.
%
%   (1) D. T. A. Nguyen, S. M. Rissanen, P. Julkunen, E. Kallioniemi, and
%   P. A. Karjalainen, Principal Component Regression on Motor Evoked
%   Potential in Single-Pulse Transcranial Magnetic Stimulation, IEEE
%   Transactions on Neural Systems and Rehabilitation Engineering, vol. 27,
%   no. 8. pp. 1521-1528, 2019. doi: 10.1109/TNSRE.2019.2923724.
%   
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%% Description on main.m
% main.m itself:
%   (1) verifies the package's functions before the first use 
%   (2) run on one dataset
%   (3) runs on all use cases, which performs the feature extraction on
%   seven stimulation paradigms.
%
%% create configuration var
close all;
clear 

% Define working folder
dir_root = 'F:\MEPFeatX\';
cd(dir_root)
addpath([dir_root 'core\'])
addpath([dir_root 'use_cases\'])

%% Verify the toolbox before the first use
disp(repmat('=', 1, 100))
config = make_config(dir_root);
time_now = char(datetime('now', 'Format', 'yyyyMMdd_HHmmSS'));
diary([config.path_ref 'verifying_MEPFeatX_' time_now '.txt'])
verify_functionality
diary off

%% Perform feature extraction on one dataset
disp(repmat('=', 1, 100))
disp('Perform feature extraction on one dataset')
file_name = 'ID09.mat';

time_now = char(datetime('now', 'Format', 'yyyyMMdd_HHmmSS'));
config = make_config(dir_root);
diary([config.path_log 'MEPFeatX_CO_analysis_' file_name(1:end-4) '_' time_now '.txt'])
tic

% Read onset table and metadata table
onset_threshold = readtable(config.onset_threshold, 'ReadRowNames',true);
metadata = readtable(config.metadata);

cur_metadata = metadata(contains(metadata.MEPs, file_name),:);

% Use the dataset's metadata to get threshold value from onset table
config = get_threshold_value(onset_threshold, ...
    cur_metadata.AgeGroup, cur_metadata.Muscle, config);
% config.plotIt = 1; % set to 1 to plot all MEP figures
% config.thresholds.t = -50:1/config.fs:150; % ID07 time vector from -50ms to 150ms

% change the template suitable for the paradigm if needed
extract_features_RC(config, file_name)

toc
diary off
%% Run all datasets listed in metadata table
time_now = char(datetime('now', 'Format', 'yyyyMMdd_HHmmSS'));
config = make_config(dir_root);
diary([config.path_log 'MEPFeatX_CO_analysis_' time_now '.txt'])
tic
disp(repmat('=', 1, 100))
disp('Perform feature extraction on all datasets listed in the metadata table')

% Read onset table and metadata table
onset_threshold = readtable(config.onset_threshold, 'ReadRowNames',true);
metadata = readtable(config.metadata);

% for k = 1:height(metadata)
% Comment the above line and uncomment three following lines to run MEPFeatX in parallel mode    
parfor k = 1:height(metadata)
    config = make_config(dir_root);
    config.plotIt = 1;

    % load metadata of the dataset
    cur_metadata = metadata(k,:);

    disp(repmat('=', 1, 50))
    file_name = cur_metadata.MEPs{:};
    if isempty(file_name)
        disp('No available information on the current dataset')
        continue
    end

    disp(file_name)
      
    % base on metadata to get threshold value
    config = get_threshold_value(onset_threshold, ...
        cur_metadata.AgeGroup, cur_metadata.Muscle, config);

    % Run feature extraction based on the dataset's paradigm

    if contains(cur_metadata.Paradigm, "LICI")
        extract_features_LICI(config, file_name)
    elseif contains(cur_metadata.Paradigm, "RS")
        extract_features_RS(config, file_name)
    elseif contains(cur_metadata.Paradigm, "SICF")
        extract_features_SICF(config, file_name)     
    elseif contains(cur_metadata.Paradigm, "RC")
        extract_features_RC(config, file_name)    
    elseif contains(cur_metadata.Paradigm, "Single")
        extract_features_singlePulse(config, file_name)
    else
        extract_features(config, file_name)
    end
end

% Create feature table for further analysis
disp(repmat('=', 1, 100))
disp('Create a table for MEP features')

config = make_config(dir_root);
create_feature_table(config)

toc
diary off

%% Plot feature boxplots for each subcategory
disp(repmat('=', 1, 100))
disp('Plot feature boxplots')
config = make_config(dir_root);
plot_feature_boxplots(config, 'Session')
plot_feature_boxplots(config, 'Muscle')
plot_feature_boxplots(config, 'Protocol')
plot_feature_boxplots(config, 'Paradigm')

