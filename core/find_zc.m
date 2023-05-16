function zc_list = find_zc(data, threshold, updown)
%% Description
% find_zc finds the zero-crossing points.
%
% Inputs:
%   data:        input vector
%   threshold:         the threshold to cross
%   updown:    define whether to detect the crossings in both ways. 1: one sign, 0: both
%
% Outputs:
%   zc_list:    zero-crossing list
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX

%updown: 1: one sign, 0: both
zc_list=[];

for k=1:length(data)-1
    if (data(k)-threshold)*(data(k+1)-threshold)<=0
        zc_list(end+1)=k;
    end
end

if updown==0
    for k=1:length(data)-1
        if (data(k)+threshold)*(data(k+1)+threshold)<0
            zc_list(end+1)=k;
        end
    end
end
zc_list=unique(zc_list);
end