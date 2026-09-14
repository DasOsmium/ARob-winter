function record_run_pitch(freq, amp)
%RECORD_RUN_PITCH Save the current pitch reference/response run to a named .mat file.
%   record_run_pitch(freq, amp) for the 4.1 frequency sweep: freq is the
%   sinusoid frequency in rad/s, amp is the commanded sine amplitude
%   (dimensionless [-1,1], the raw AT*PCMD command value).
%
%   record_run_pitch('step', amp) for the 4.3 step profile: pass the
%   string 'step' instead of a numeric frequency, and amp is the
%   commanded plateau value (0.2 per the guide). Used only to label the
%   file, since the profile itself is fixed (0 -> amp at t=15s -> 0 at
%   t=18s).
%
%   Reads thetaref_data (input, dimensionless command) and theta_data
%   (output, rad), both created by "To Workspace" blocks in Structure
%   With Time format with matching sample time/decimation, and saves
%   them - together with a ready-to-use iddata object id built from the
%   full run - into experiments_Pedro/real/pitch/, so it is not mixed up
%   with the height runs saved by record_run.m.
%
%   The full run (take-off, hold, test signal, landing) is saved as-is.
%   Cropping to the window where the test signal is active should be
%   done later, e.g. before calling nlinfit, so nothing gets discarded
%   by mistake at capture time.
%
%   Call this right after each real-drone run finishes (after landing
%   and stopping the model), before starting the next run.
%
%   Examples:
%       record_run_pitch(1, 0.1)      % omega = 1 rad/s, amplitude 0.1
%       record_run_pitch('step', 0.2) % 4.3 step profile, plateau 0.2

varNameY = 'theta_data';
varNameU = 'thetaref_data';
outDir   = fullfile(fileparts(mfilename('fullpath')), '..', 'experiments_Pedro', 'real', 'pitch');

for varName = {varNameY, varNameU}
    if ~evalin('base', sprintf('exist(''%s'',''var'')', varName{1}))
        error('record_run_pitch:noData', ...
            '%s não existe no workspace base. Corre a experiência e para-a antes de chamares esta função.', varName{1});
    end
end

Sy = evalin('base', varNameY);
Su = evalin('base', varNameU);

y = squeeze(Sy.signals.values);
u = squeeze(Su.signals.values);

if numel(y) ~= numel(u)
    error('record_run_pitch:mismatch', ...
        'theta_data (%d amostras) e thetaref_data (%d amostras) têm comprimentos diferentes - confirma que os dois blocos To Workspace têm o mesmo sample time e decimation.', ...
        numel(y), numel(u));
end

Ts = median(diff(Sy.time));
id = iddata(y(:), u(:), Ts, 'Name', sprintf('freq=%s_amp=%g', num2str(freq), amp), ...
    'InputName', 'thetaref', 'OutputName', 'theta', ...
    'InputUnit', '-', 'OutputUnit', 'rad', 'TimeUnit', 'seconds');

if ~isfolder(outDir)
    mkdir(outDir);
end

if isnumeric(freq)
    freqStr = strrep(sprintf('%g', freq), '.', 'p');
else
    freqStr = char(freq);
end
ampStr = strrep(sprintf('%g', amp), '.', 'p');
fname = fullfile(outDir, sprintf('scope_freq%s_amp%s.mat', freqStr, ampStr));

meta = struct('freq', freq, 'amp', amp, 'source', 'real', 'savedAt', datestr(now));
S = Sy;
Sref = Su;
save(fname, 'S', 'Sref', 'id', 'meta');

fprintf('Guardado: %s  (freq = %s, amp = %g, %d amostras, Ts = %.4g s)\n', ...
    fname, num2str(freq), amp, numel(y), Ts);

end
