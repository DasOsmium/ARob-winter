function record_run(kp, cumStep)
%RECORD_RUN Save the current height_data (To Workspace block) to a named .mat file.
%   record_run(kp, cumStep) saves the base workspace variable height_data
%   (created by the "To Workspace" block wired to the height signal, in
%   Structure With Time format) into a file named
%   scope_kpXX_stepYY.mat in ../experiments_Pedro/real, so it is not
%   mixed up with the simulation runs saved by simulation/record_run.m.
%
%   Call this right after each real-drone run finishes (after landing
%   and stopping the model), before starting the next run.
%
%   Example:
%       record_run(0.5, 1.0)   % kp = 0.5, cumulative step = 1.0 m

varName = 'height_data';
outDir  = fullfile(fileparts(mfilename('fullpath')), '..', 'experiments_Pedro', 'real');

if ~isfolder(outDir)
    mkdir(outDir);
end

if ~evalin('base', sprintf('exist(''%s'',''var'')', varName))
    error('record_run:noData', ...
        '%s não existe no workspace base. Corre a experiência e para-a antes de chamares esta função.', varName);
end

S = evalin('base', varName);

kpStr   = strrep(sprintf('%g', kp), '.', 'p');
stepStr = strrep(sprintf('%g', cumStep), '.', 'p');
fname = fullfile(outDir, sprintf('scope_kp%s_step%s.mat', kpStr, stepStr));

meta = struct('kp', kp, 'cumulativeStep', cumStep, 'source', 'real', 'savedAt', datestr(now));
save(fname, 'S', 'meta');

fprintf('Guardado: %s  (kp = %g, step = %g m, %d amostras)\n', ...
    fname, kp, cumStep, numel(S.time));

end
