% Question 4.2 - fit of a 2nd order system with a minimum-phase zero
% to the experimental closed-loop pitch amplitude data, using nlinfit.
%
% Model:      G(s) = K*(s + z) / (s^2 + 2*zeta*wn*s + wn^2)
% Amplitude:  |G(jw)| = K*sqrt(w^2 + z^2) / sqrt((wn^2 - w^2)^2 + 4*zeta^2*wn^2*w^2)
% Parameters (4): p = [K, z, wn, zeta]

clear; clc;

% Experimental data
w    = [1 5 10 15 20];                         % [rad/s]
Aref = [0.1 0.2 0.3 0.4 0.5];                  % [rad]
Ares = [0.0450 0.0998 0.0796 0.0542 0.0353];   % [rad]
amp  = Ares ./ Aref;                           % amplitude ratio |G(jw)|

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
