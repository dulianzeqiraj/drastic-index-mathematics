% m06_voi
% Preposterior value of monitoring: for each candidate family, invent 10
% stations at area-weighted profiles of that family, simulate their responses
% from the current posterior's hypermean with sigma-level noise, refit the
% model, and measure the reduction of the undecided share (P_modal < 0.7).
% Averaged over rehearsals. Requires: profilet.mat, bayes_draws.mat, m04_profile.mat.

[DATA, RES] = paths_repo();
WD = [5 4 3 2 1 5 3]';
FAMS = {'aluvional', 'karbonatik', 'magmatik', 'flish_argjile'};
PAR = 'DRASTIC';
THR = [55 90 125 160];
F = 4; d = 7;
load(fullfile(RES, 'profilet.mat'), 'Runiq', 'counts');
load(fullfile(RES, 'bayes_draws.mat'), 'U3', 'rbar');
load(fullfile(RES, 'm04_profile.mat'), 'famu');

raw = fileread(fullfile(DATA, 'kalibrimi_62_pika.json'));
pts = jsondecode(raw);
if ~iscell(pts), pts = num2cell(pts); end
n0 = numel(pts);
X0 = zeros(n0, d); y0 = zeros(n0, 1); se0 = zeros(n0, 1); fam0 = zeros(n0, 1);
for i = 1:n0
    for p = 1:d
        X0(i, p) = pts{i}.rates.(PAR(p));
    end
    y0(i) = pts{i}.no3;
    if isfield(pts{i}, 'se_no3') && ~isempty(pts{i}.se_no3)
        se0(i) = pts{i}.se_no3;
    end
    fam0(i) = find(strcmp(FAMS, pts{i}.familja));
end

baza = zeros(1, F);
for f = 1:F
    baza(f) = undecided_share(U3, f, famu, Runiq, counts, THR);
end
fprintf('base undecided: %s\n', mat2str(round(baza, 3)));

rng(77, 'twister');
rez06 = struct();
rez06.baza_pavendosur = round(baza, 4);
scen = {2, 'karbonatik', 3; 4, 'flish_argjile', 3; 1, 'aluvional', 2};
mu_hat = squeeze(mean(mean(U3, 1), 2));      % hypermean of unnormalized u
for s = 1:size(scen, 1)
    f_add = scen{s, 1};
    emri = scen{s, 2};
    reps = scen{s, 3};
    reduks = zeros(1, reps);
    for rep = 1:reps
        sel = find(famu == f_add);
        pw = counts(sel) / sum(counts(sel));
        pick = sel(weighted_draw(pw, 10));
        Xn = Runiq(pick, :);
        yn = max((Xn - rbar) * mu_hat + mean(y0) + 6.9 * randn(10, 1), 0.1);
        X = [X0; Xn]; y = [y0; yn];
        se2 = [se0.^2; ones(10, 1)];
        fam = [fam0; f_add * ones(10, 1)];
        Xc = X - rbar;
        ch = run_chain_hier(9000, 4000, 500 + 10*f_add + rep, Xc, y, se2, fam, ...
                            F, d, WD, mean(y), 6.0);
        nd = size(ch, 1);
        Un = zeros(nd, F, d);
        for f = 1:F
            Un(:, f, :) = ch(:, (f-1)*d + (1:d));
        end
        u_new = undecided_share(Un, f_add, famu, Runiq, counts, THR);
        reduks(rep) = baza(f_add) - u_new;
        fprintf('  %s rep %d: %.3f -> %.3f\n', emri, rep, baza(f_add), u_new);
    end
    rez06.(emri) = round(100 * mean(reduks), 1);
    fprintf('%s +10 stations: mean reduction %.1f pp\n', emri, rez06.(emri));
end
save(fullfile(RES, 'm06_rez.mat'), 'rez06');
fprintf('m06 done.\n');

function u = undecided_share(Udraws, f, famu, Runiq, counts, THR)
sel = famu == f;
Uf = squeeze(Udraws(:, f, :));
s = sum(Uf, 2);
ok = s > 1e-9;
Wn = 23 * Uf(ok, :) ./ s(ok);
DI = Wn * Runiq(sel, :)';
Kc = klasa_di(DI, THR);
Pk = zeros(nnz(sel), 5);
for k = 1:5
    Pk(:, k) = mean(Kc == k, 1)';
end
Pm = max(Pk, [], 2);
w = counts(sel);
u = sum((Pm < 0.7) .* w) / sum(w);
end

function idx = weighted_draw(p, m)
% m indices drawn with replacement with probabilities p (column vector)
cp = cumsum(p(:)) / sum(p);
idx = zeros(m, 1);
for t = 1:m
    idx(t) = find(rand <= cp, 1);
end
end
