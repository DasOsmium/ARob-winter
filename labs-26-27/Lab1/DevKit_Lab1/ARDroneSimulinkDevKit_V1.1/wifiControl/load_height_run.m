function d = load_height_run(file)
%LOAD_HEIGHT_RUN Load a height run saved as dadosaltura<href>_<kp>.mat.
%   d = load_height_run(file) reads height, href_data and Kp_h from FILE
%   and returns a struct with the signals in plain column vectors:
%       d.t        time (s)
%       d.y        height h (m)
%       d.u        reference (m): 0.75 until the reference change, then
%                  the href of the run
%       d.tStep    time of the reference change (s), from the jump of
%                  states(:,3) back to 0 when the height loop is closed
%       d.ref0     initial reference, 0.75 m
%       d.Ts       sample time (s)
%       d.kp       proportional gain used in the run
%       d.cumStep  reference step (m): href minus 0.75

L = load(file, 'height', 'href_data', 'Kp_h', 'states');
d.t  = L.height.time(:);
d.y  = reshape(squeeze(L.height.signals.values), [], 1);
href = L.href_data.signals.values(end);
d.Ts = median(diff(d.t));
d.kp = double(L.Kp_h);

% the reference change is the second jump of states(:,3): takeoff, loop
% closed, landing. h only reacts to it a few samples later.
z  = squeeze(L.states.signals.values(:, 3));
iJ = find(abs(diff(z)) > 1);
if numel(iJ) < 3
    error('load_height_run:noStep', 'Esperava 3 saltos em states(:,3) em %s.', file);
end
d.tStep = d.t(iJ(2) + 1);

d.ref0 = 0.75;
d.u = d.ref0 * ones(size(d.t));
d.u(d.t >= d.tStep) = href;
d.cumStep = href - d.ref0;
end
