%PLOT_HEIGHT_STEPS Load the 4 saved runs from record_run.m and overlay them.
%   Edit the "files" list below to match the files record_run produced.
%   This script only displays the figure - it does not save anything to
%   disk. Use export_height_steps.m when you want to save the PDF/PNG.

dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'experiments_Pedro');

files = { ...
    fullfile(dataDir, 'scope_kp0p5_step1.mat'), ...
    fullfile(dataDir, 'scope_kp1_step0p8.mat'), ...
    fullfile(dataDir, 'scope_kp2_step0p3.mat'), ...
    fullfile(dataDir, 'scope_kp3_step0p2.mat'), ...
    };

% --- Formatting conventions ---
fontName    = 'Helvetica';
titleSize   = 14;
labelSize   = 12;
tickSize    = 10;
legendSize  = 10;
lineWidth   = 1.5;
figSize_in  = [6 4];   % width x height, inches - fits a single-column report

fig = figure('Units', 'inches', 'Position', [1 1 figSize_in], 'Renderer', 'painters');
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');
box(ax, 'on');

legends = {};
for k = 1:numel(files)
    if ~isfile(files{k})
        warning('Ficheiro não encontrado, salto: %s', files{k});
        continue
    end
    d = load(files{k});
    plot(ax, d.S.time, squeeze(d.S.signals.values), 'LineWidth', lineWidth);
    legends{end+1} = sprintf('k_p = %g (step %g m)', d.meta.kp, d.meta.cumulativeStep); %#ok<SAGROW>
end

xlabel(ax, 'Tempo (s)', 'FontName', fontName, 'FontSize', labelSize);
ylabel(ax, 'Altura (m)', 'FontName', fontName, 'FontSize', labelSize);
title(ax, 'Resposta ao degrau da altura para diferentes k_p (Questão 3.1)', ...
    'FontName', fontName, 'FontSize', titleSize, 'FontWeight', 'bold');

lgd = legend(ax, legends, 'Location', 'best');
set(lgd, 'FontName', fontName, 'FontSize', legendSize);

set(ax, 'FontName', fontName, 'FontSize', tickSize, 'LineWidth', 1);
