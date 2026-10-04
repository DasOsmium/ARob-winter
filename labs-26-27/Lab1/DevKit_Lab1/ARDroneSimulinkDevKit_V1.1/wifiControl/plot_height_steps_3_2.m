%PLOT_HEIGHT_STEPS_3_2 Question 3.2: reference, simulated and real height step per kp.
%   One panel per gain (Table 1), time axis with t = 0 at the reference
%   change so the real and simulated runs line up, and each panel starts
%   before the take-off so the 0 -> 0.75 m jump is shown too. The real runs come from
%   experiments_Pedro/real (dadosaltura*.mat), the simulated ones from
%   experiments_Pedro/artificial (scope_kp*.mat). A gain without a real run
%   shows only the reference and the simulation. This script only displays
%   the figure - it does not save anything to disk.

realDir = fullfile(fileparts(mfilename('fullpath')), '..', 'experiments_Pedro', 'real');
simDir  = fullfile(fileparts(mfilename('fullpath')), '..', 'experiments_Pedro', 'artificial');

% kp, cumulative step (Table 1), simulated file, real file ('' = none),
% delay (s) of the simulated step after the reference change, to match
% the moment the real h starts to rise (Kp=2: step at x = 0.27 s)
runs = { ...
    0.5, 1.0, 'scope_kp0p5_step1.mat',   'dadosaltura1.75_0.5.mat', 0; ...
    1.0, 0.8, 'scope_kp1_step0p8.mat',   'dadosaltura1.55_1.mat', 0.33; ...
    2.0, 0.3, 'scope_kp2_step0p3.mat',   'dadosaltura1.05_2.mat', 0.27; ...
    3.0, 0.2, 'scope_kp3_step0p2.mat',   '', 0};

ref0      = 0.75;   % initial reference (m)
onsetH    = 1e-3;   % h above this (m) marks the start of the rise (first non-zero reading)
tSimDef   = 15;     % seconds after the change when there is no real run

% --- Formatting conventions ---
fontName    = 'Helvetica';
titleSize   = 12;
labelSize   = 11;
tickSize    = 10;
legendSize  = 9;
lineWidth   = 1.5;

fig = figure('Units', 'inches', 'Position', [1 1 9 6.5], 'Renderer', 'painters');
tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

for k = 1:size(runs, 1)
    kp = runs{k, 1};  cumStep = runs{k, 2};
    ax = nexttile(tl);  hold(ax, 'on');  grid(ax, 'on');  box(ax, 'on');

    % real run: t = 0 at the reference change, ends where the fit window ends
    hasReal = ~isempty(runs{k, 4});
    if hasReal
        d   = load_height_run(fullfile(realDir, runs{k, 4}));
        idw = height_iddata(d);
        tR  = d.t - d.tStep;
        yR  = d.y;
        tOnR = tR(find(yR > onsetH, 1));
        tEnd = (d.t(find(d.t >= d.tStep - 2.5, 1)) - d.tStep) + (size(idw.y, 1) - 1) * d.Ts;
    else
        tEnd = tSimDef;
    end

    % simulated run: the change is the last time at 0.75 before the rise
    L  = load(fullfile(simDir, runs{k, 3}), 'S');
    tS = L.S.time(:);
    yS = reshape(squeeze(L.S.signals.values), [], 1);
    iRise = find(yS >= ref0 + 0.5 * cumStep, 1);
    iStep = find(abs(yS(1:iRise) - ref0) <= 0.003, 1, 'last');
    tS = tS - tS(iStep);

    % the simulation hovers much longer than the real run before the step.
    % Remove one block of consecutive samples (the data are otherwise kept
    % exactly as in the file) so the take-off and the step both line up with
    % the real run. The block is placed where its two ends have the same
    % height, i.e. in the flat hover, so the splice is as small as possible.
    if hasReal
        tOnS = tS(find(yS > onsetH, 1));
        n = round((tOnR - tOnS) / median(diff(tS)));   % samples to remove
        iOn = find(yS > onsetH, 1);
        if n >= 1
            idx = (iOn + n + 1):iStep;
            gap = abs(yS(idx) - yS(idx - n));
            iB  = idx(find(gap <= min(gap) + 1e-4, 1, 'last'));
            shift = tS(iB) - tS(iB - n);
            tS(1:iB - n - 1) = tS(1:iB - n - 1) + shift;
            tS(iB - n:iB - 1) = [];
            yS(iB - n:iB - 1) = [];
            tS(iB - n:end) = tS(iB - n:end) + runs{k, 5};   % delay the step
        else
            tS = tS + (tOnR - tOnS);
        end
    end
    tOnS = tS(find(yS > onsetH, 1));

    % the reference jump 0 -> 0.75 is drawn where the take-off starts
    % (the commanded instant is not logged); window starts 1 s before it
    if hasReal, tOn = tOnR; else, tOn = tOnS; end
    tPre = 1 - min([tOnS, tOn]);
    m  = tS >= -tPre & tS <= tEnd;

    tRef = [-tPre tOn tOn 0 0 tEnd];
    yRef = [0 0 ref0 ref0 ref0 + cumStep ref0 + cumStep];
    plot(ax, tRef, yRef, 'k--', 'LineWidth', 1);
    plot(ax, tS(m), yS(m), 'LineWidth', lineWidth);
    names = {'Referência', 'Simulado'};
    if hasReal
        mR = tR >= -tPre & tR <= tEnd;
        plot(ax, tR(mR), yR(mR), 'LineWidth', lineWidth);
        names{end+1} = 'Real';
    else
        text(ax, 0.97, 0.06, 'sem dados reais', 'Units', 'normalized', ...
            'HorizontalAlignment', 'right', 'FontName', fontName, 'FontSize', tickSize);
    end

    xlim(ax, [-tPre tEnd]);
    title(ax, sprintf('k_p = %g (degrau %g m)', kp, cumStep), ...
        'FontName', fontName, 'FontSize', titleSize);
    lgd = legend(ax, names, 'Location', 'southeast');
    set(lgd, 'FontName', fontName, 'FontSize', legendSize);
    set(ax, 'FontName', fontName, 'FontSize', tickSize, 'LineWidth', 1);
end

xlabel(tl, 'Tempo desde a mudança da referência (s)', 'FontName', fontName, 'FontSize', labelSize);
ylabel(tl, 'Altura (m)', 'FontName', fontName, 'FontSize', labelSize);
title(tl, 'Resposta ao degrau da altura: referência, simulação e real (Questão 3.2)', ...
    'FontName', fontName, 'FontSize', titleSize + 2, 'FontWeight', 'bold');
