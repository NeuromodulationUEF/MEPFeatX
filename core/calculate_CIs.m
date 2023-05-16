function meps_CIs = calculate_CIs(meps, CI_bounds)
%% Description
% calculate_CI calculates the confidence intervals for the current dataset
% using t-distribution.
%
% Inputs:
%   meps:     dataset to calculate CIs
%   CI_bounds:  confidence intervals boundary.
%
% Output:
%   meps_CIs: confidence intervals of the dataset
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


num_trials = size(meps, 2);
meps_mean =  mean(meps, 2);
meps_sem = std(meps, 0, 2)/sqrt(num_trials);
meps_CI_bounds = tinv([(1 - CI_bounds)/2 (1+CI_bounds)/2], num_trials-1);
meps_CIs = bsxfun(@times, meps_sem, meps_CI_bounds);
meps_CIs = [meps_mean + meps_CIs(:,1), meps_mean + meps_CIs(:,2)];
