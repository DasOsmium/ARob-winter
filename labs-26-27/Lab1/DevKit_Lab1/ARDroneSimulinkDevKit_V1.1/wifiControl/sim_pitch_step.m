% Question 4.3 - compare the pitch response of the model from 4.2 with the
% real response of the drone to the reference: 0 for t < 15 s,
% 0.2 for 15 <= t < 18 s, 0 for t >= 18 s.
%
% Model:  G(s) = K*(s + z) / (s^2 + 2*zeta*wn*s + wn^2)
%
% The .mat file must contain the recorded run as Structure With Time,
% either as theta_data / thetaref_data (raw workspace variables) or as
% S / Sref (saved by record_run_pitch).
% The model is driven by the reference recorded in the file.
% If matFile is empty, only the model is simulated with the ideal reference.

clear; clc; close all;

% Data file
matFile = '';   % e.g. '../experiments_Pedro/real/pitch/scope_freqstep_amp0p2.mat'; '' = model only

% Model parameters (from 4.2)
K    = 0.944;
z    = 23.98;         % rad/s (zero at s = -z, minimum phase)
wn   = sqrt(50.67);   % rad/s
zeta = 7.72/(2*wn);

% Window around the pulse and offset handling
tPre  = 5;            % s shown before the pulse
tPost = 10;           % s shown after the pulse
removeOffset = true;  % subtract the mean theta before the pulse (trim)

hasReal = ~isempty(matFile);

if hasReal
    % Load the recorded run
    d = load(matFile);
    if isfield(d, 'theta_data') && isfield(d, 'thetaref_data')
        Sy = d.theta_data;  Su = d.thetaref_data;
    elseif isfield(d, 'S') && isfield(d, 'Sref')
        Sy = d.S;           Su = d.Sref;
    else
        error('%s must contain theta_data/thetaref_data or S/Sref.', matFile);
    end
    t    = Sy.time(:);
    y    = squeeze(Sy.signals.values);  y = y(:);
    uref = squeeze(Su.signals.values);  uref = uref(:);

    % Locate the pulse in the recorded reference and crop a window around it
    on   = abs(uref) > 0.5*max(abs(uref));
    tOn  = t(find(on, 1, 'first'));
    tOff = t(find(on, 1, 'last'));
    Ts   = median(diff(t));
    tg   = (max(t(1), tOn - tPre) : Ts : min(t(end), tOff + tPost))';
    u    = interp1(t, uref, tg);
    y    = interp1(t, y, tg);
    if removeOffset
        y = y - mean(y(tg < tOn - 0.5));
    end
else
    % Default: ideal reference, model only
    Ts = 0.03;
    tg = (0:Ts:30)';
    u  = 0.2*(tg >= 15 & tg < 18);
end

% Model simulation
s  = tf('s');
G  = K*(s + z) / (s^2 + 2*zeta*wn*s + wn^2);
ym = lsim(G, u, tg - tg(1));

% Plot (and RMSE between model and real, if there is real data)
figure;
if hasReal
    fprintf('RMSE (model vs real) = %.4f rad\n', rmse(y, ym));
    plot(tg, u, '--', tg, y, tg, ym, 'LineWidth', 1.2);
    legend('\theta_{ref}', '\theta (real)', '\theta (model)');
else
    plot(tg, u, '--', tg, ym, 'LineWidth', 1.2);
    legend('\theta_{ref}', '\theta (model)');
end
grid on;
xlabel('t (s)');
ylabel('\theta (rad)');
title('Pitch response to the reference of 4.3');
