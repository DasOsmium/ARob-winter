function idw = height_iddata(d)
%HEIGHT_IDDATA Crop a height run around the step and load it into an iddata.
%   idw = height_iddata(d), with d from load_height_run: keeps the window
%   from 2.5 s before the step until 0.3 s before the landing, subtracts
%   the initial reference (0.75 m) from h and from the reference, so the data start
%   at rest and the model works with deviations.

tStep = d.tStep;
y0 = d.ref0;

% landing: h falls 8 cm below the step level, but only after it first
% came within 4 cm of it (otherwise slow runs, e.g. kp = 0.5, are cut during the rise)
iReach = find(d.t > tStep & (d.y - y0) >= d.cumStep - 0.04, 1);
if isempty(iReach)
    iReach = numel(d.t);
end
iLand = iReach - 1 + find(d.t(iReach:end) > tStep + 3 & (d.y(iReach:end) - y0) < d.cumStep - 0.08, 1);
if isempty(iLand)
    iLand = numel(d.t);
end
w = find(d.t >= tStep - 2.5, 1) : iLand - round(0.3 / d.Ts);

idw = iddata(d.y(w) - y0, d.u(w) - y0, d.Ts);
end
