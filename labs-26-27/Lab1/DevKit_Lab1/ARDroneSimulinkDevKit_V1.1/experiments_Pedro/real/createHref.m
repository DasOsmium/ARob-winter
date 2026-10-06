function href = createHref(height_data, takeoff, t_step, land, init, step_size)
%CREATEHREF undefined
%   undefined

t = height_data.time;

href = zeros(size(t));

href(t >= takeoff) = init;
href(t >= t_step) = init + step_size;
href(t >= land) = 0;
