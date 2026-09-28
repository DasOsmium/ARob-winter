function d = load_height_run(file)
%LOAD_HEIGHT_RUN Load a height run saved by record_run(kp, cumStep).
%   d = load_height_run(file) reads S (height), Sref (href) and meta from
%   FILE and returns a struct with the signals in plain column vectors:
%       d.t        time (s)
%       d.y        height h (m)
%       d.u        reference href (m)
%       d.Ts       sample time (s)
%       d.kp       proportional gain used in the run
%       d.cumStep  commanded cumulative step (m)

L = load(file, 'S', 'Sref', 'meta');
d.t  = L.S.time(:);
d.y  = reshape(squeeze(L.S.signals.values), [], 1);
d.u  = reshape(squeeze(L.Sref.signals.values), [], 1);
d.Ts = median(diff(d.t));
d.kp = L.meta.kp;
d.cumStep = L.meta.cumulativeStep;
end
