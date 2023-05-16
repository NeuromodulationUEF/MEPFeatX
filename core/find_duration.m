function [iDur_end, sateline_threshold] = find_duration(m, it, iy, t2t, dur_thresh, baseline_threshold, amp_threshold)
%% Description
% find_duration finds the end point of MEP.
%
% Inputs:
%   m:          the order of the response in the dataset
%   it:         vector of time samples.
%   iy:         preprocessed response
%   t2t:        the timepoint of the second major turn
%   dur_thresh:         pre-defined threshold for duration
%   baseline_threshold: threshold calculated from background activity
%   amp_threshold:  threshold calculated from the peak-to-peak amplitude
%
% Outputs:
%   iDur_end:           the end point of MEP
%   sateline_threshold: activity level near the end point of MEP
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX



roi = it>=t2t + 5 & it <= dur_thresh(2) + 21;
t = it(roi);
y = abs(iy(roi));

ind = find_zc(y, amp_threshold, 1);

if ~isempty(ind)
    ind(t(ind) > dur_thresh(2) - 5) = [];
    if ~isempty(ind)
        y = y(ind(end):end);
        t = t(ind(end):end);
    end
end

zc_list = find_zc(y, baseline_threshold, 1);
median_list = find_zc(y, median(y), 1);

zc_list(t(zc_list) > dur_thresh(2)) = [];
median_list(t(median_list) > dur_thresh(2)) = [];

if isempty(median_list)
    amp_increment = 3*mad(y);
    n = 2000;
    while(isempty(median_list) || ...
            all(t(median_list) > dur_thresh(2)))
        n = n-1;
        median_list = find_zc(y, median(y) + amp_increment, 0);
        if (amp_increment > max(y) && isempty(median_list)) || n == 0
            disp([num2str(m), ': duration infinite loop'])
            return;
        end
        amp_increment = amp_increment + baseline_threshold;
    end
end
%looking for 20ms that has 1.2 median of satelite and mad less than
%baseline variation
median_list(median_list+600 > length(y))=[];

try
    end_points_satelite = zeros(length(median_list), 2);
    for kk = 1:length(median_list)
        cur_satelite = y(median_list(kk):median_list(kk) + 600);
        end_points_satelite(kk, :) = [median(cur_satelite) mad(cur_satelite)];
    end
    end_point_index = median_list(find(end_points_satelite(:,2) <= baseline_threshold, 1));
catch
    end_point_index = median_list(1);
end

if isempty(end_point_index)
    end_point_index = median_list(1);
end

if ~isempty(zc_list)
    [~, closest_zc_index]= min(abs(end_point_index-zc_list));
    end_point_index = zc_list(closest_zc_index);
end

sateline_threshold = 3*mad(y(end_point_index:end_point_index + 600));
iDur_end = [t(end_point_index) y(end_point_index)];
