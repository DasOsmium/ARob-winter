function record_run(kp, cumStep)
%RECORD_RUN Save the current height/reference run to a named .mat file.
%   record_run(kp, cumStep) reads the base workspace variables
%   height_data (output h) and href_data (input href), both created by
%   "To Workspace" blocks in Structure With Time format with matching
%   sample time/decimation, and saves them - together with a ready-to-use
%   iddata object id built from the full run - into a file named
%   scope_kpXX_stepYY.mat in ../experiments_Pedro/real, so it is not
%   mixed up with the simulation runs saved by simulation/record_run.m.
%
%   The full run (take-off, hold, step, landing) is saved as-is. Cropping
%   to the window around the 0.75 m equilibrium (dropping take-off and
%   landing transients) should be done later, e.g. before calling
%   tfest/procest, so nothing gets discarded by mistake at capture time.
%
%   Call this right after each real-drone run finishes (after landing
%   and stopping the model), before starting the next run.
%
%   Example:
%       record_run(0.5, 1.0)   % kp = 0.5, cumulative step = 1.0 m

varNameY = 'height_data';
varNameU = 'href_data';
outDir   = fullfile(fileparts(mfilename('fullpath')), '..', 'experiments_Pedro', 'real');

for varName = {varNameY, varNameU}
    if ~evalin('base', sprintf('exist(''%s'',''var'')', varName{1}))
        error('record_run:noData', ...
            '%s não existe no workspace base. Corre a experiência e para-a antes de chamares esta função.', varName{1});
    end
end

Sy = evalin('base', varNameY);
Su = evalin('base', varNameU);

y = squeeze(Sy.signals.values);
u = squeeze(Su.signals.values);

if numel(y) ~= numel(u)
    error('record_run:mismatch', ...
        'height_data (%d amostras) e href_data (%d amostras) têm comprimentos diferentes - confirma que os dois blocos To Workspace têm o mesmo sample time e decimation.', ...
        numel(y), numel(u));
end

Ts = median(diff(Sy.time));
id = iddata(y(:), u(:), Ts, 'Name', sprintf('kp=%g_step=%g', kp, cumStep), ...
    'InputName', 'href', 'OutputName', 'h', ...
    'InputUnit', 'm', 'OutputUnit', 'm', 'TimeUnit', 'seconds');

if ~isfolder(outDir)
    mkdir(outDir);
end

kpStr   = strrep(sprintf('%g', kp), '.', 'p');
stepStr = strrep(sprintf('%g', cumStep), '.', 'p');
fname = fullfile(outDir, sprintf('scope_kp%s_step%s.mat', kpStr, stepStr));

meta = struct('kp', kp, 'cumulativeStep', cumStep, 'source', 'real', 'savedAt', datestr(now));
S = Sy;
Sref = Su;
save(fname, 'S', 'Sref', 'id', 'meta');

fprintf('Guardado: %s  (kp = %g, step = %g m, %d amostras, Ts = %.4g s)\n', ...
    fname, kp, cumStep, numel(y), Ts);

end
