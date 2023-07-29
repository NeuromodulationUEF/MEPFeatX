function all_features = extract_feature_all(meps, raw_meps, config)
%% Description
% extract_feature_all sets up the feature extraction for each MEP. If the
% feature extraction is failed, the miss one is also noted and outputed for
% evaluation. 
% 
% For more detail in exclusion criteria for MEPs, please check the related
% publication.
% 
%
% Inputs:
%   meps:       dataset of preprocessed responses
%   raw_meps:   dataset of raw responses
%   config:     config file for controlling the feature extraction
%
% Outputs:
%   all_features:      matrix of features extracted from the input dataset
%
%   If config.plotIt is 1, the function also visualizes the missed
%   responses.
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%%
warning('off','signal:findpeaks:largeMinPeakHeight');
warning('off','MATLAB:catenate:DimensionMismatch');
%
if isempty(raw_meps)
    raw_meps = NaN(size(meps));
end

% Set region of interest according to the configured time window
plotIt = config.plotIt;
thresholds = config.thresholds;
plotOpt = config.plotOpt;
t = thresholds.t;

%%
num_features = length(config.features);
all_features = NaN(size(meps, 2), num_features);

for k = 1:size(meps,2)
    try
        % Extract features from each response
        [features, turns] = extract_feature_each(k, t, meps(:,k), raw_meps(:,k), thresholds, plotIt, plotOpt);
        all_features(k, :) = [features turns(1:4) turns(3)-turns(1) abs(turns(2)./turns(4))];

    catch
        % If feature extraction fails, still plot the response, and note
        % that the current MEP features are NaN
        if plotIt
            figure('color', 'w', 'Name', num2str(k), 'Position', [0 0 plotOpt.figure_size]);

            hold on
            plot(t, raw_meps(:,k), 'g')
            plot(t, meps(:,k), 'color', plotOpt.color_MEP_individual);
            hold off

            title(int2str(k))
            axis ij; grid minor
            xlabel('Time (ms)'); ylabel('Amplitude (\muV)')
        end
        % Set all features to zero if MEP amplitude is too small
        y_roi_abs = meps(t > thresholds.t_onset(1) & t < thresholds.t_onset(2) + 40, k);
        p2p = abs( max(y_roi_abs)) + abs(min(y_roi_abs));
        if p2p < thresholds.amp_min
            all_features(k, :) = zeros(1, num_features);
        end
    end

end
