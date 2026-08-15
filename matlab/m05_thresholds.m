% m05_thresholds
% Solves the max-margin threshold redesign program (eq. 9 of the manuscript;
% its solution is eq. 10) on the archived index raster SAKTE_DI_100m.asc,
% which stores the
% index at a resolution of 0.01 index points (569 attained values). For each
% threshold in turn, the widest gap between consecutive attained values is
% chosen subject to holding the cumulative area share below the threshold
% within delta/2 of its official value, which enforces every class share
% within delta (each class share is a difference of two cumulative shares).

[DATA, RES] = paths_repo();
THR = [55 90 125 160];
ref = read_asc(fullfile(DATA, 'SAKTE_DI_100m.asc'));
v = ref(ref ~= -9999);
[vals, ~, iv] = unique(v);
valc = accumarray(iv, 1);
w = 100 * valc / sum(valc);
cumw = cumsum(w);
kk = klasa_di(vals, THR);
offshare = accumarray(kk, w, [5 1]);

g = (vals(2:end) - vals(1:end-1)) / 2;   % half-gap widths
mid = (vals(2:end) + vals(1:end-1)) / 2; % candidate thresholds
cumbelow = cumw(1:end-1);                % area share strictly below each candidate

rez05 = struct();
rez05.vlera_te_arritura = numel(vals);
rez05.pjeset_zyrtare_pct = round(offshare', 2);
labels = {'d1', 'd2', 'd5'};
deltas = [1 2 5];
CumPct = cumsum(offshare); CumPct = CumPct(1:4);
for t = 1:3
    delta = deltas(t);
    c = zeros(1, 4);
    for k = 1:4
        gk = g;
        gk(abs(cumbelow - CumPct(k)) > delta / 2) = -inf;
        [~, j] = max(gk);                % first occurrence of the widest gap
        c(k) = mid(j);
    end
    kk2 = klasa_di(vals, c);
    newshare = accumarray(kk2, w, [5 1]);
    minmarg = min(min(abs(vals - c), [], 2));
    sol = struct();
    sol.pragjet = round(c, 4);
    sol.marzhi_min = round(minmarg, 4);
    sol.pjeset_e_reja_pct = round(newshare', 2);
    sol.zhvendosja_max_pp = round(max(abs(newshare - offshare)), 2);
    rez05.(labels{t}) = sol;
    fprintf('delta=%g: c=%s  marzh=%.4f  shift=%.2f  pjeset=%s\n', delta, ...
        mat2str(sol.pragjet), sol.marzhi_min, sol.zhvendosja_max_pp, mat2str(sol.pjeset_e_reja_pct));
end
save(fullfile(RES, 'm05_rez.mat'), 'rez05');
fprintf('m05 done.\n');
