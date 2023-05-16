function save_figures(path_to_save, runParallel)
%% Description
% save_figures save all current figures.
%
% Inputs:
%   path_to_save:          folder to save the figures
%   runParallel:         save the figure in parallel
%
%
% Copyright (c) 2023, NeuromodulationUEF.
% Github: https://github.com/NeuromodulationUEF/MEPFeatX


if ~exist(path_to_save, "dir")
    mkdir(path_to_save)
end

figure_list = findobj(allchild(0), 'flat', 'Type', 'figure');
if runParallel
    parfor f = 1:length(figure_list)
        figure_handle = figure_list(f);
        figure_file = [path_to_save figure_handle.Name '.png'];
        print(figure_handle, '-r300', '-dpng', figure_file);
    end
else
    for f = 1:length(figure_list)
        figure_handle = figure_list(f);
        figure_file = [path_to_save figure_handle.Name '.png'];
        print(figure_handle, '-r300', '-dpng', figure_file);
    end
end
close all;