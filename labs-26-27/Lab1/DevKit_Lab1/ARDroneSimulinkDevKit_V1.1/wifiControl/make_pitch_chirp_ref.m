function make_pitch_chirp_ref(doPlot)
%MAKE_PITCH_CHIRP_REF Build a logarithmic chirp pitch reference for the 4.1 experiment.
%   make_pitch_chirp_ref() generates the reference and saves it in
%   wifiControl/pitch_refs/pitch_ref_chirp.mat.
%   make_pitch_chirp_ref(false) does the same without plotting.
%
%   The reference is a sine whose frequency grows exponentially from w1 to
%   w2 (rad/s), so that one flight excites the whole range [1, 20] rad/s
%   of the guide (Sec. 4.1). The amplitude grows linearly from A1 to A2,
%   because the closed-loop gain drops with frequency and the response at
%   high frequency would otherwise be buried in noise.
%
%   The phase starts at zero and the signal is cut at the last zero
%   crossing before T, so the reference starts at 0 and ends within one
%   sample of 0 (the last sample can be off by at most the sine's own
%   sample-to-sample change at w2). A tail of zeros is appended after it.
%
%   The amplitude is the raw pitch command in [-1, 1] (same unit as the
%   Sine Wave block amplitude pitchAmp in ARDroneHoverPitch.slx).
%
%   Saved variables:
%       pitchRef  Nx2 matrix [time, value], ready for a From Workspace block
%       Ts        sample time (s), same as sampleTime in setupHoverPitch.m
%       chirpCfg  struct with w1, w2, A1, A2, T (design), tEnd (last zero crossing)
%
%   To get the frequency response from a flight, use the recorded
%   thetaref_data (input) and theta_data (output), e.g. with the System
%   Identification Toolbox:
%       id = iddata(y, u, Ts);   G = etfe(id);   bode(G)

if nargin < 1
    doPlot = true;
end

Ts = 0.03;   % s, sampleTime of the model and of the Sine Wave block
w1 = 1;      % rad/s, start frequency
w2 = 20;     % rad/s, end frequency
A1 = 0.2;    % command units, amplitude at w1
A2 = 0.5;    % command units, amplitude at w2
T  = 40;     % s, design duration of the sweep
tTail = 1;   % s of zeros appended after the sweep

if max(A1, A2) > 1
    error('make_pitch_chirp_ref:amp', 'Amplitude above 1 saturates the command.');
end

k = log(w2 / w1);
phaseAt = @(t) w1 * T / k * (exp(t * k / T) - 1);   % phase of the log sweep (rad)

% Cut at the last zero crossing before T: phase = m*pi.
phaseEnd = floor(phaseAt(T) / pi) * pi;
tEnd = T / k * log(1 + phaseEnd * k / (w1 * T));

t = (0:Ts:(tEnd + tTail))';
u = zeros(size(t));
idx = t < tEnd;
A = A1 + (A2 - A1) * t(idx) / T;
u(idx) = A .* sin(phaseAt(t(idx)));

pitchRef = [t, u]; %#ok<NASGU>
chirpCfg = struct('w1', w1, 'w2', w2, 'A1', A1, 'A2', A2, 'T', T, 'tEnd', tEnd); %#ok<NASGU>

outDir = fullfile(fileparts(mfilename('fullpath')), 'pitch_refs');
if ~isfolder(outDir)
    mkdir(outDir);
end
fname = fullfile(outDir, 'pitch_ref_chirp.mat');
save(fname, 'pitchRef', 'Ts', 'chirpCfg');

wEnd = w1 * exp(tEnd * k / T);
fprintf('chirp: omega %g -> %.2f rad/s, A %g -> %.2f, %.1f s (+%g s tail), max|u| = %.2f\n', ...
    w1, wEnd, A1, A1 + (A2 - A1) * tEnd / T, tEnd, tTail, max(abs(u)));
fprintf('    samples per period at the end: %.1f\n', 2*pi / wEnd / Ts);
fprintf('    saved: %s\n', fname);

if doPlot
    figure('Name', 'Pitch chirp reference', 'Color', 'w');
    subplot(2, 1, 1);
    plot(t, u, 'b-'); grid on;
    xlim([0, t(end)]);
    ylabel('command');
    title(sprintf('Log chirp, \\omega = %g to %.1f rad/s, A = %g to %.2f', w1, wEnd, A1, A2));
    subplot(2, 1, 2);
    plot(t(idx), w1 * exp(t(idx) * k / T), 'r-'); grid on;
    xlim([0, t(end)]);
    ylabel('\omega (rad/s)');
    xlabel('t (s)');
    title('Instantaneous frequency');
end

end
