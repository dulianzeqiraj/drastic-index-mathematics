% m03_hierarchical_bayes
% Fits the hierarchical Bayesian weight model on the 62-point national
% calibration dataset: 4 chains x 24,000 iterations of component-wise
% Metropolis, adaptation during burn-in, thinning by 10, split-free R-hat.
% Then: sum-23 posterior summaries per family, sigma posterior, a 3,000-draw
% subsample for deployment, and the 8-fold alluvial cross-validation.
% Requires: kalibrimi_62_pika.json.

[DATA, RES] = paths_repo();
WD = [5 4 3 2 1 5 3]';
FAMS = {'aluvional', 'karbonatik', 'magmatik', 'flish_argjile'};
PAR = 'DRASTIC';
F = 4; d = 7;

raw = fileread(fullfile(DATA, 'kalibrimi_62_pika.json'));
pts = jsondecode(raw);
if ~iscell(pts), pts = num2cell(pts); end
n = numel(pts);
X = zeros(n, d); y = zeros(n, 1); se = zeros(n, 1); fam = zeros(n, 1);
for i = 1:n
    for p = 1:d
        X(i, p) = pts{i}.rates.(PAR(p));
    end
    y(i) = pts{i}.no3;
    if isfield(pts{i}, 'se_no3') && ~isempty(pts{i}.se_no3)
        se(i) = pts{i}.se_no3;
    end
    fam(i) = find(strcmp(FAMS, pts{i}.familja));
end
rbar = mean(X, 1);
Xc = X - rbar;
ybar = mean(y);
se2 = se.^2;
fprintf('n=%d; points per family: %s\n', n, mat2str(accumarray(fam, 1, [F 1])'));

ITERS = 24000; BURN = 8000;
chains = cell(1, 4);
for c = 1:4
    tchain = tic;
    chains{c} = run_chain_hier(ITERS, BURN, 100 + c, Xc, y, se2, fam, F, d, WD, ybar, 5.0);
    fprintf('chain %d: %d draws, %.0f s\n', c, size(chains{c}, 1), toc(tchain));
end

% R-hat over the 4 chains
L = min(cellfun(@(c) size(c, 1), chains));
DIM = F*d + F + d + d + 1;
A = zeros(4, L, DIM);
for c = 1:4
    A(c, :, :) = chains{c}(1:L, :);
end
Wj = squeeze(mean(var(A, 0, 2), 1))';
Bj = L * squeeze(var(mean(A, 2), 0, 1))';
Rhat = sqrt((Wj * (L - 1) / L + Bj / L) ./ max(Wj, 1e-12));
fprintf('R-hat max: %.3f\n', max(Rhat));

S = vertcat(chains{:});
nd = size(S, 1);
U = zeros(nd, F, d);
for f = 1:F
    U(:, f, :) = S(:, (f-1)*d + (1:d));
end
sigma = exp(S(:, end));

rez03 = struct();
rez03.n_draws = nd;
rez03.rhat_max = round(max(Rhat), 3);
rez03.sigma_mediana = round(median(sigma), 2);
rez03.sigma_ci95 = round(pctl(sigma, [2.5 97.5]), 2);
for f = 1:F
    Uf = squeeze(U(:, f, :));
    s = sum(Uf, 2);
    ok = s > 1e-9;
    Wn = 23 * Uf(ok, :) ./ s(ok);
    med = zeros(1, d); lo = zeros(1, d); hi = zeros(1, d);
    for p = 1:d
        med(p) = median(Wn(:, p));
        q = pctl(Wn(:, p), [2.5 97.5]);
        lo(p) = q(1); hi(p) = q(2);
    end
    rez03.(FAMS{f}) = struct('mediana', round(med, 2), 'ci_lo', round(lo, 2), ...
                             'ci_hi', round(hi, 2));
    fprintf('%s medians: %s\n', FAMS{f}, mat2str(round(med, 2)));
end
fprintf('sigma: %.2f [%.2f, %.2f]\n', rez03.sigma_mediana, rez03.sigma_ci95(1), rez03.sigma_ci95(2));

% 3,000-draw subsample for deployment
rng(2026, 'twister');
idx = randperm(nd, 3000);
U3 = U(idx, :, :);
b3 = S(idx, F*d + (1:F));
sigma3 = sigma(idx);
save(fullfile(RES, 'bayes_draws.mat'), 'U3', 'b3', 'sigma3', 'rbar', '-v7.3');

% 8-fold CV over the alluvial points (short refits), against sd of alluvial y
al = find(fam == 1);
rng(2027, 'twister');
perm = al(randperm(numel(al)));
edges = round(linspace(0, numel(al), 9));
errs = [];
for fold = 1:8
    holdix = perm(edges(fold)+1 : edges(fold+1));
    keep = setdiff((1:n)', holdix);
    ch = run_chain_hier(6000, 3000, 1000 + fold, Xc(keep, :), y(keep), se2(keep), ...
                        fam(keep), F, d, WD, mean(y(keep)), 5.0);
    Um = zeros(F, d);
    for f = 1:F
        Um(f, :) = median(ch(:, (f-1)*d + (1:d)), 1);
    end
    bm = median(ch(:, F*d + (1:F)), 1)';
    pred = bm(fam(holdix)) + sum(Xc(holdix, :) .* Um(fam(holdix), :), 2);
    errs = [errs; (y(holdix) - pred).^2]; %#ok<AGROW>
end
rez03.cv_rmse = round(sqrt(mean(errs)), 2);
rez03.sd_y_aluvional = round(std(y(al)), 2);
fprintf('CV RMSE %.2f vs sd(y_al) %.2f\n', rez03.cv_rmse, rez03.sd_y_aluvional);

save(fullfile(RES, 'm03_rez.mat'), 'rez03');
fprintf('m03 done.\n');
