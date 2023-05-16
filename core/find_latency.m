function latency = find_latency(m, it, iy, lat_thresh, baseline_threshold, amp_threshold)
%% Description
% find_latency finds the onset of MEP.
%
% Inputs:
%   m:          the order of the response in the dataset
%   it:         vector of time samples.
%   iy:         preprocessed response
%   lat_thresh:         pre-defined threshold for latency
%   baseline_threshold: threshold calculated from background activity
%   amp_threshold:  threshold calculated from the peak-to-peak amplitude
%
% Outputs:
%   latency:           MEP latency
%   sateline_threshold: activity near the end point of MEP
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


lat_ROI = it >= lat_thresh(1) & it <= lat_thresh(2);
lat_amp = abs(iy(lat_ROI));
lat_time = it(lat_ROI);

% [peaks, ind] = findpeaks(abs(lat_amp), 'minPeakHeight', bl_threshold+15, 'MinPeakProminence', 15); % 15 15
[peaks, ind] = findpeaks(lat_amp, 'minPeakHeight', amp_threshold);

if ~isempty(ind)
    [~, xx] = max(peaks);
    lat_ROI = it >= lat_thresh(1) & it < lat_time(ind(xx));
    lat_amp = abs(iy(lat_ROI));
    lat_time = it(lat_ROI);
end

zc_list = find_zc(lat_amp, baseline_threshold, 0);

amp_increment = 5;
n = 2000;
while(isempty(zc_list))
    n = n-1;
    zc_list = find_zc(lat_amp, baseline_threshold + amp_increment, 0);
    amp_increment = amp_increment + 1;
    if (baseline_threshold + amp_increment > amp_threshold) || (n == 0)
        %         if isempty(zc_list)
        % %             disp([num2str(m), ': latency infinite loop'])
        %             break;
        %         else
        disp([num2str(m), ': Latency infinite loop'])
        break;
    end
end

if isempty(zc_list)
    zc_list = find_zc(diff(lat_amp), 0, 0);
    if isempty(zc_list)
        disp([num2str(m), ': unable to detect onset'])
        return;
    end
end

onset = zc_list(end);

zc_amp = lat_amp(zc_list);
if all(zc_amp > baseline_threshold*3)
    [~, ind] = min(zc_amp);
    onset = zc_list(ind);
elseif length(zc_list) >= 3
    cur_latency_time_range = lat_time(zc_list(1):zc_list(end));
    cur_latency_amp_range = lat_amp(zc_list(1):zc_list(end));
    [~, loc] = findpeaks(cur_latency_amp_range, 'MinPeakHeight', baseline_threshold*3);

    if ~isempty(loc)
        lat_point = find_zc(lat_time(zc_list) - cur_latency_time_range(loc(1)), 0, 1);
        onset = zc_list(lat_point);
    end
end

latency = lat_time(onset);

if isnan(latency)
    disp([num2str(m), ': unable to detect onset'])
    return;
end

end
