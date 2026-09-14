%EXPORT_HEIGHT_STEPS Build the height-step plot (via plot_height_steps)
%   and save it as PDF (vector, for the LaTeX report) and PNG (600 dpi
%   preview) inside experiments_Pedro/.

dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'experiments_Pedro');
outName = fullfile(dataDir, 'height_step_responses');

plot_height_steps;
fig = gcf;

exportgraphics(fig, [outName '.pdf'], 'ContentType', 'vector');
exportgraphics(fig, [outName '.png'], 'Resolution', 600);

fprintf('Gráfico gravado em %s.pdf e %s.png\n', outName, outName);
