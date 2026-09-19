% m06_voi_dense
% Preposterior value of ten new monitoring stations, for each of the four aquifer
% families, over REPS rehearsals apiece. A rehearsal draws ten station profiles from
% the area-weighted profile law of the family, draws their responses from the current
% posterior predictive, refits the hierarchy, redeploys, and measures how much of the
% family stops being undecided. The spread over rehearsals is wide, so the mean is
% reported with its Monte Carlo standard error rather than on its own.
% Requires: profilet.mat, bayes_draws.mat, m04_profile.mat.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

REPS = 40;

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
fprintf('base undecided: %s\n', mat2str(round(baza, 4)));

rez = struct();
rez.reps = REPS;
rez.baza_pavendosur = round(baza, 4);
rez.familjet = FAMS;
mu_hat = squeeze(mean(mean(U3, 1), 2));
allred = zeros(F, REPS);
tvoi = tic;
for f_add = 1:F
    emri = FAMS{f_add};
    reduks = zeros(1, REPS);
    for rep = 1:REPS
        % seeds disjoint across families: 100000 + 1000*family + replicate
        rng(100000 + 1000*f_add + rep, 'twister');
        sel = find(famu == f_add);
        pw = counts(sel) / sum(counts(sel));
        pick = sel(weighted_draw(pw, 10));
        Xn = Runiq(pick, :);
        yn = max((Xn - rbar) * mu_hat + mean(y0) + 6.9 * randn(10, 1), 0.1);
        X = [X0; Xn]; y = [y0; yn];
        se2 = [se0.^2; ones(10, 1)];
        fam = [fam0; f_add * ones(10, 1)];
        Xc = X - rbar;
        ch = run_chain_hier(9000, 4000, 200000 + 1000*f_add + rep, Xc, y, se2, fam, ...
                            F, d, WD, mean(y), 6.0);
        nd = size(ch, 1);
        Un = zeros(nd, F, d);
        for f = 1:F
            Un(:, f, :) = ch(:, (f-1)*d + (1:d));
        end
        u_new = undecided_share(Un, f_add, famu, Runiq, counts, THR);
        reduks(rep) = baza(f_add) - u_new;
        fprintf('  %-14s rep %3d/%d: %.4f -> %.4f  (%.1f pp)  [%.0f s]\n', ...
                emri, rep, REPS, baza(f_add), u_new, 100*reduks(rep), toc(tvoi));
    end
    allred(f_add, :) = reduks;
    m = 100 * mean(reduks);
    s = 100 * std(reduks);
    se = s / sqrt(REPS);
    rez.(emri) = struct('mesatare_pp', round(m, 2), 'sd_pp', round(s, 2), ...
                        'se_pp', round(se, 2), ...
                        'ci95_pp', round([m - 1.96*se, m + 1.96*se], 2), ...
                        'min_pp', round(100*min(reduks), 2), ...
                        'max_pp', round(100*max(reduks), 2));
    fprintf('%-14s +10 stations: %.2f pp  (sd %.2f, se %.2f, 95%% CI %.2f to %.2f)\n', ...
            emri, m, s, se, m - 1.96*se, m + 1.96*se);
end
rez.reduktimet_pp = round(100 * allred, 3);
save(fullfile(RES, 'm06_dense.mat'), 'rez', 'allred');
fid = fopen(fullfile(RES, 'voi_dense.json'), 'w');
fprintf(fid, '%s', jsonencode(rez, 'PrettyPrint', true));
fclose(fid);
fprintf('m06_voi_dense done in %.0f s.\n', toc(tvoi));

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
cp = cumsum(p(:)) / sum(p);
idx = zeros(m, 1);
for t = 1:m
    idx(t) = find(rand <= cp, 1);
end
end
