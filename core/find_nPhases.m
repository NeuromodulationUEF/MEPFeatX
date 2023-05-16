function [nPhases, phase_dur2] = find_nPhases(it, iy, ...
    latency, t_end, t_turns, sateline_threshold)
%% Description
% find_nPhases finds the phases of MEP.
%
% Inputs:
%   it:         vector of time samples.
%   iy:         preprocessed response
%   latency:    MEP onset
%   t_end:      MEP endpoint
%   t_turns:    time points turns
%   sateline_threshold: activity level near the end point of MEP
%
% Outputs:
%   nPhases:    number of phases
%   phase_dur2: phase areas
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


t=it(it>=t_turns(1)&it<=t_turns(end));
y=iy(it>=t_turns(1)&it<=t_turns(end));

zc_spike=find_zc(y,sateline_threshold,0);
zc_spike(diff(t(zc_spike))<1.5)=[]; % remove close zc

if t_end(1)-t(zc_spike(end)) >10
    zc_spike(end+1)=length(t);
end

phase_dur= [latency t(zc_spike) t_end(1)];
phase_dur2 = [];
for k=1:length(zc_spike)-1
    roi = t>=phase_dur(k)&t<phase_dur(k+1);
    if any(ismember(t_turns, t(roi)))
        phase_dur2(end+1) = phase_dur(k+1);
    else
        phase_dur2(end) = phase_dur(k+1);
    end 
end
phase_dur2 = [latency phase_dur2 t_end];
% nPhases = length(phase_dur2)-1;
nPhases = max(length(phase_dur2)-1,2);
end