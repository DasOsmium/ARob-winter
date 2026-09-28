function idw = height_iddata(d)
%HEIGHT_IDDATA Crop a height run around the step and load it into an iddata.
%   idw = height_iddata(d), with d from load_height_run: keeps the window
%   from 2.5 s before the step until 0.3 s before the landing, subtracts
%   the hover level of h and the initial value of href, so the data start
%   at rest and the model works with deviations.

iStep = find(abs(d.u - d.u(1)) > 0.5 * abs(d.cumStep), 1);
if isempty(iStep)
    error('height_iddata:noStep', 'Não encontrei o degrau em href_data.');
end
tStep = d.t(iStep);

y0 = median(d.y(d.t >= tStep - 2.5 & d.t < tStep));

iLand = find(d.t > tStep + 3 & (d.y - y0) < 0.7 * d.cumStep, 1);
if isempty(iLand)
    iLand = numel(d.t);
end
w = find(d.t >= tStep - 2.5, 1) : iLand - round(0.3 / d.Ts);

idw = iddata(d.y(w) - y0, d.u(w) - d.u(1), d.Ts);
end
