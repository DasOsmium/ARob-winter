% Question 4.2 - fit of a 2nd order system with a minimum-phase zero
% to the experimental closed-loop pitch amplitude data, using nlinfit.
%
% Model:      G(s) = K*(s + z) / (s^2 + 2*zeta*wn*s + wn^2)
% Amplitude:  |G(jw)| = K*sqrt(w^2 + z^2) / sqrt((wn^2 - w^2)^2 + 4*zeta^2*wn^2*w^2)
% Parameters (4): p = [K, z, wn, zeta]

clear; clc;

% Experimental data: amplitude of the steady-state pitch response, taken
% from the recorded runs (Question 4.1).
%
% Each run contains take-off, hover, the test sinusoid and landing, so only
% the window where the sinusoid is already in steady state is used. The
% windows [t0 t1] (s) were chosen by inspecting the run: t0 is after the
% switch-on transient, t1 is before landing. The window is then shortened
% to an integer number of periods. In that window the pitch is fitted with
%   theta(t) = a*sin(w t) + b*cos(w t) + c
% (the offset c absorbs the hover trim), and the amplitude is hypot(a, b).
% This uses all the samples of the window, instead of reading peaks, so it
% is not biased upwards by noise. The phase atan2(b, a) is also reported.
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'experiments_Pedro', 'real');
runs = struct( ...
    'file', {'theta_data_w01_A0p1.mat', 'theta_data_w05_A0p2.mat', 'theta_data_w10_A0p3.mat', ...
             'theta_data_w15_A0p4.mat', 'theta_data_w20_A0p5.mat'}, ...
    'w',    {1, 5, 10, 15, 20}, ...              % [rad/s]
    'Aref', {0.1, 0.2, 0.3, 0.4, 0.5}, ...       % commanded amplitude
    'win',  {[14 48], [17 30], [12 19.5], [12.5 21], [9.5 15]});

n    = numel(runs);
w    = zeros(1, n);
Aref = zeros(1, n);
Ares = zeros(1, n);
phi  = zeros(1, n);
for i = 1:n
    D = load(fullfile(dataDir, runs(i).file), 'theta_data');
    t = D.theta_data.time(:);
    y = squeeze(D.theta_data.signals.values);
    y = y(:);
    wi = runs(i).w;
    T  = 2*pi/wi;
    t0 = runs(i).win(1);
    t1 = t0 + floor((runs(i).win(2) - t0)/T)*T;   % integer number of periods
    m  = t >= t0 & t <= t1;
    X  = [sin(wi*t(m)), cos(wi*t(m)), ones(nnz(m), 1)];
    c  = X \ y(m);
    w(i)    = wi;
    Aref(i) = runs(i).Aref;
    Ares(i) = hypot(c(1), c(2));
    phi(i)  = atan2(c(2), c(1));
    fprintf('w = %2d rad/s: window [%.1f, %.1f] s (%d periods), Ares = %.4f, phase = %.0f deg\n', ...
        wi, t0, t1, round((t1 - t0)/T), Ares(i), rad2deg(phi(i)));
end
amp = Ares ./ Aref;                            % amplitude ratio |G(jw)|

% Amplitude model (38). The magnitude does not depend on the sign of z.
model = @(p, w) p(1)*sqrt(w.^2 + p(2)^2) ./ ...
    sqrt((p(3)^2 - w.^2).^2 + 4*p(4)^2*p(3)^2*w.^2);

% Initial guess [K, z, wn, zeta]
p0 = [1, 20, 7, 0.5];

[p, R] = nlinfit(w, amp, model, p0);

K = p(1); z = abs(p(2)); wn = abs(p(3)); zeta = abs(p(4));

fprintf('Estimated parameters:\n');
fprintf('  K    = %.4f\n', K);
fprintf('  z    = %.4f rad/s (zero at s = -z, minimum phase)\n', z);
fprintf('  wn   = %.4f rad/s\n', wn);
fprintf('  zeta = %.4f\n', zeta);
fprintf('  RMSE = %.4g (amplitude ratio)\n', sqrt(mean(R.^2)));

s = tf('s');
G = K*(s + z) / (s^2 + 2*zeta*wn*s + wn^2)

% Bode magnitude plot: fitted curve (line) and experimental points (crosses).
wg = logspace(log10(0.5), log10(40), 500);      % [rad/s]
Gw = squeeze(freqresp(G, wg));                  % complex response on the grid

% Fixed size in inches, so the saved image does not depend on the screen.
fig = figure('Name', 'Closed-loop pitch Bode', 'Color', 'w', ...
    'Units', 'inches', 'Position', [0.5 0.5 12 7.5]);
ax = axes(fig);
semilogx(ax, wg, 20*log10(abs(Gw)), 'b-', 'LineWidth', 2.5); hold(ax, 'on');
semilogx(ax, w, 20*log10(amp), 'rx', 'MarkerSize', 16, 'LineWidth', 3);
grid(ax, 'on'); ax.XMinorGrid = 'on'; ax.YMinorGrid = 'on';
ax.FontSize = 16;
ax.XLim = [0.5 40];
ax.XTick = [0.5 1 2 5 10 20 40];
ax.XTickLabel = {'0.5', '1', '2', '5', '10', '20', '40'};
ylim(ax, [5*floor(min(20*log10(amp))/5 - 0.5), 5*ceil(max(20*log10(amp))/5 + 0.5)]);
xlabel(ax, 'Frequency \omega [rad/s]', 'FontSize', 18);
ylabel(ax, 'Gain [dB]', 'FontSize', 18);
title(ax, 'Bode Diagram - Obtained Model Fit for Pitch Dynamics', 'FontSize', 18);
legend(ax, 'Fitted model G(s)', 'Experimental points', 'Location', 'southwest', 'FontSize', 16);

% Save the figure automatically for the report in Lab1/report:
%   fig_pitch_bode.png  raster, 600 dpi
%   fig_pitch_bode.pdf  vector (no loss of quality at any zoom)
% Padding adds a margin around the axes, so labels and title are not cropped.
outDir = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', 'report');
if ~isfolder(outDir)
    mkdir(outDir);
end
outPng = fullfile(outDir, 'fig_pitch_bode.png');
outPdf = fullfile(outDir, 'fig_pitch_bode.pdf');
try
    exportgraphics(fig, outPng, 'Resolution', 600, 'Padding', 30, 'BackgroundColor', 'white');
    exportgraphics(fig, outPdf, 'ContentType', 'vector', 'Padding', 30, 'BackgroundColor', 'white');
catch
    % MATLAB without the Padding option: add the margin by hand.
    ax.Units = 'normalized'; ax.OuterPosition = [0.02 0.02 0.96 0.96];
    exportgraphics(fig, outPng, 'Resolution', 600, 'BackgroundColor', 'white');
    exportgraphics(fig, outPdf, 'ContentType', 'vector', 'BackgroundColor', 'white');
end
fprintf('Figures saved: %s and %s\n', outPng, outPdf);
