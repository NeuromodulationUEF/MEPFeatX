function thresholds = get_threshold_value(onset_table, sbj, muscle, fs)
%% Description
% get_threshold_value calculate the thresholds for the current dataset.
%
% Inputs:
%   onset_table:          look-up table for latency threshold
%   sbj:         subject group, either "Child" or "Adult"
%   muscle:         target muscle
%   fs:         sampling frequency
%
% Outputs:
%   thresholds:          threshold list
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


if strcmp(sbj, "Child")
    if strcmp(muscle, "BB")
        t_onset = [onset_table.Child_low("biceps") onset_table.Child_high("biceps")];
    elseif contains(muscle, ["ECR", "FCR"])
        t_onset = [onset_table.Child_low("forearm") onset_table.Child_high("forearm")];
    elseif contains(muscle, ["APB", "ADM", "FDI"])
        t_onset = [onset_table.Child_low("hand") onset_table.Child_high("hand")];
    end
elseif strcmp(sbj, "Adult")
    if strcmp(muscle, "BB")
        t_onset = [onset_table.Adult_low("biceps") onset_table.Adult_high("biceps")];
    elseif contains(muscle, ["ECR", "FCR"])
        t_onset = [onset_table.Adult_low("forearm") onset_table.Adult_high("forearm")];
    elseif contains(muscle, ["APB", "ADM", "FDI"])
        t_onset = [onset_table.Adult_low("hand") onset_table.Adult_high("hand")];
    elseif contains(muscle, "TA")
        t_onset = [onset_table.Adult_low("tibialis") onset_table.Adult_high("tibialis")];
    end
else
    disp('Fail to get threshold value')
    return;
end

if contains(muscle, "TA")
    thresholds.t = -50:1/fs:150; % time vector from -50ms to 150ms
else
    thresholds.t = -50:1/fs:100; % time vector from -50ms to 100ms
end

thresholds.amp_min = 50; % minimum MEP amplitude
thresholds.t_background = [-40, -5]; % background to calculate background signal

thresholds.t_onset = t_onset; % time window for MEP onset
thresholds.t_end_point = [t_onset(1) + 8, t_onset(1) + 60]; % range for end-points of MEP in ms
thresholds.t_first_peak = t_onset(1) + 2; % earliest time-point of the first major peak

