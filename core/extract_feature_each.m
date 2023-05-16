function [features, turns_info] = extract_feature_each(m, t, y, raw_y, thresholds, plotIt, plotOpt)
%% Description
% extract_feature_each extract features from an individual MEP.
% 
% For more detail in extraction algorithm, please check the related
% publication.
%
% Inputs:
%   m:          the order of the response in the dataset
%   t:          vector of time samples.
%   y:          preprocessed response
%   raw_y:      raw response
%   thresholds: pre-defined thresholding values
%   plotIt:     plot the response with its features
%   plotOpt:    plot options
%
% Outputs:
%   features:      extracted features from the input response
%   turns_info:    time-point and amplitude of all the turns detected in
%               the response
%   If plotIt is 1, the function also visualizes the response and its features.
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


%% feature extraction
% Recall threshold for MEP features
t_onset = thresholds.t_onset;
t_end_point = thresholds.t_end_point;
amp_min = thresholds.amp_min;
t_background = thresholds.t_background;

% Upsample MEP 10 times to optain higher precision
it = linspace(t(1), t(end), length(t)*10);
iy = interp1(t, y, it, 'spline');

% Find background activity levels
background = iy(it > t_background(1) & it < t_background(2));
iy = iy - mean(background);
baseline_threshold = 3*mad(background);
baseline_p2p = 6*mad(background);

% Find two largest peaks
roi_peaks = it > t_onset(1) & it < t_onset(2) + 40;
t_roi = it(roi_peaks);
y_roi_abs = iy(roi_peaks);
[t1a, t1_index] = max(y_roi_abs);
t1t = t_roi(t1_index);
[t2a, t2_index] = min(y_roi_abs);
t2t = t_roi(t2_index);

% Check if the positive peak appears before the negative peaks. If yes,
% flip the signal and these peaks' info.
posMep = 0;
if t2t - t1t < 0
    posMep = 1;
    iy = -iy;
    y_roi_abs = iy(roi_peaks);
    [t1a, t1_index] = max(y_roi_abs);

    t1t = t_roi(t1_index);
    [t2a, t2_index] = min(y_roi_abs);
    t2t = t_roi(t2_index);
end

% Calculate peak-to-peak amplitude
p2p = abs(t1a) + abs(t2a);

% Return if
% - MEP amplitude is less than 50,
% - Baseline is noisy
% - The first peak appears outside of the duration range
if p2p < amp_min || abs(t1a) < baseline_threshold || ...
        baseline_threshold > p2p*0.2 || max(t1t, t2t) > t_end_point(2) || ...
        t1t > t2t || isempty(t2t) || t1t < thresholds.t_first_peak
    disp([num2str(m) ': failed to extract features'])
    return;
end

% Re-define threshold for longest latency to be the timing of the first
% peak
t_onset(2) = min(t_onset(2), t1t);

% Amplitude threshold where baseline becomes signal
amp_threshold = min(abs(p2p*0.1), 50);

% Find latency and terminal-included duration
latency = find_latency(m, it, iy, t_onset, baseline_threshold, amp_threshold);
[duration_end, sateline_threshold] = find_duration(m, it, iy, t2t, t_end_point, baseline_threshold, amp_threshold);
duration = duration_end(1) - latency;

% Define spiky period and find turns
spike_ROI = find(it > latency & it < duration_end(1));
spike_y = iy(spike_ROI);
tt = it(spike_ROI);

[~, spike_ind1] = findpeaks(spike_y, 'minPeakHeight', amp_threshold, 'minpeakprominence', baseline_p2p/2);
[~, spike_ind2] = findpeaks(-spike_y, 'minPeakHeight', amp_threshold, 'minpeakprominence', baseline_p2p/2);

spike_ind = sort([spike_ind1 spike_ind2]);

turns = [tt(spike_ind)' spike_y(spike_ind)'];
turns(abs(turns(:, 2)) < baseline_p2p, :) = [];

if isempty(turns)
    disp([num2str(m) ': no turn info'])
    return;
end

nTurns = size(turns,1);
remain_turns = turns(:,2)~=t1a & turns(:,2)~=t2a;
turns1 = [t1t t1a; t2t t2a; turns(remain_turns,:)];

% Flip the signal back if it was flipped before
if posMep
    iy = -iy;
    t1a = -t1a;
    t2a = -t2a;
    turns(:,2) = -turns(:,2);
end
turns_info = reshape(turns1',1,[]);

% Find number of phases
[nPhases, phase_dur] = find_nPhases(it, iy, latency, duration_end(1), turns(:,1), sateline_threshold);

% Find area_under_the_curve, thickness and size_index
roi = it >= latency & it < duration_end(1);
AUC = trapz(it(roi), abs(iy(roi)));
thickness = AUC/p2p; % estimated duration in ms based on AUC and p2p
% size_index = 2*log10(p2p) + thickness; % unused

% Feature list
features = [p2p, latency, AUC, thickness, nTurns, nPhases, duration];

if plotIt
    % Plot the current response with its features

    figure('color', 'w', 'Name', num2str(m), 'Position', [0 0 plotOpt.figure_size]);

    hold on;
    plot(t, raw_y, 'g')
    plot(it, iy, 'color', plotOpt.color_MEP_individual);
    line([it(1) it(end)], [baseline_threshold baseline_threshold], 'linestyle','--');
    line([it(1) it(end)], [-baseline_threshold -baseline_threshold], 'linestyle','--');
    line([duration_end(1) it(end)], [-sateline_threshold -sateline_threshold], 'linestyle', '-.', 'color', 'b');
    line([duration_end(1) it(end)], [sateline_threshold sateline_threshold], 'linestyle', '-.', 'color', 'b');

    line([latency latency], [t1a t2a], 'color', 'r', 'linestyle', '--');
    line([duration_end(1) duration_end(1)], [t1a t2a], 'color', 'b', 'linestyle', '--');

    plot(t1t, t1a, 'rv')
    plot(t2t, t2a, 'rv')
    plot(turns(:,1), turns(:,2), 'r*')
    for k = 1:length(phase_dur) - 1
        roi = it >= phase_dur(k) & it < phase_dur(k+1);
        area(it(roi), iy(roi), 'Facecolor', plotOpt.color_MEP_mean, ...
            'Facealpha',0.2*k, ...
            'Edgecolor', plotOpt.color_MEP_individual);
    end
    hold off

    title(num2str(m))
    axis ij; grid minor
    xlabel('Time (ms)'); ylabel('Amplitude (\muV)')
    legend('Raw MEP', 'Processed MEP', 'Baseline+', 'Baseline-', 'Sateline+', 'Sateline-', ...
        'Onset', 'Endpoint', 'T1', 'T2', 'Turns', 'AUC', ...
        'Location', 'northeastoutside');
end
end