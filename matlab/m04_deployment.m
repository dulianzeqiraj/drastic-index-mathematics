% m04_deployment
% Deploys the posterior nationally over the unique (family, profile)
% combinations: class-probability field, modal class and its probability,
% undecided shares, chamber distinctness, draw-pair map instability, and
% the margin-probability bridge (standardized margin, Chebyshev bound).
% Requires: profilet.mat (m01), bayes_draws.mat (m03).

W = [5 4 3 2 1 5 3];
THR = [55 90 125 160];
FAMS = {'aluvional', 'karbonatik', 'magmatik', 'flish_argjile'};
[~, RES] = paths_repo();
load(fullfile(RES, 'profilet.mat'), 'Runiq', 'counts', 'ic', 'mask');
load(fullfile(RES, 'bayes_draws.mat'), 'U3');
K = size(Runiq, 1);
B = size(U3, 1);

% family of each profile, from the aquifer-media rating (as in the archived pipeline)
Ar = Runiq(:, 3);
famu = 4 * ones(K, 1);
famu(Ar >= 3.5) = 3;
famu(Ar >= 6.5) = 2;
famu(Ar >= 8) = 1;

% sum-23 normalization per draw and family
Un = zeros(B, 4, 7);
for f = 1:4
    Uf = squeeze(U3(:, f, :));
    s = sum(Uf, 2);
    ok = s > 1e-9;
    Un(ok, f, :) = 23 * Uf(ok, :) ./ s(ok);
end

% deployed index per draw and profile (timed: this is the deployment step of
% Section 8.1, Step 3, the only part whose cost scales with B times K)
tdep = tic;
DI_all = zeros(B, K);
for f = 1:4
    sel = famu == f;
    DI_all(:, sel) = squeeze(Un(:, f, :)) * Runiq(sel, :)';
end
Kd = uint8(klasa_di(DI_all, THR));

Pk = zeros(K, 5);
for k = 1:5
    Pk(:, k) = mean(Kd == k, 1)';
end
[Pmax, Kmod] = max(Pk, [], 2);
t_deploy = toc(tdep);
fprintf('deployment step (%d draws x %d combinations): %.2f s\n', B, K, t_deploy);

% area-weighted national and family statistics
wA = counts / sum(counts);
% t_deploy is printed to the log, not stored: matlab_verifikimi.json must be a
% pure function of the inputs and the fixed seeds, and a runtime is not.
rez04 = struct();
rez04.draws = B;
rez04.P_mesatare = round(sum(Pmax .* wA), 3);
rez04.mbi_090_pct = round(100 * sum((Pmax >= 0.9) .* wA), 1);
rez04.nen_070_pct = round(100 * sum((Pmax < 0.7) .* wA), 1);
kk0 = klasa_di(Runiq * W', THR);
rez04.modal_ndryshe_nga_konsensusi_pct = round(100 * sum((Kmod ~= kk0) .* wA), 1);
for f = 1:4
    sel = famu == f;
    wf = counts(sel) / sum(counts(sel));
    rez04.(['nen_070_' FAMS{f}]) = round(100 * sum((Pmax(sel) < 0.7) .* wf), 1);
    if f == 1
        rez04.modal_ndryshe_aluvional_pct = ...
            round(100 * sum((Kmod(sel) ~= kk0(sel)) .* wf), 1);
    end
end

% chamber distinctness: distinct national class maps among the B draws
rez04.harta_te_dallueshme = size(unique(Kd, 'rows'), 1);

% instability: area-weighted class disagreement between random draw pairs
rng(7, 'twister');
npair = 400;
dis = zeros(npair, 1);
for t = 1:npair
    ij = randperm(B, 2);
    dis(t) = 100 * sum((Kd(ij(1), :) ~= Kd(ij(2), :))' .* wA);
end
rez04.paqendrueshmeria_mes_pct = round(mean(dis), 1);
rez04.paqendrueshmeria_iqr = round(pctl(dis, [25 75]), 1);

% margin-probability bridge
Dbar = mean(DI_all, 1)';
sD = std(DI_all, 0, 1)';
gam = min(abs(Dbar - THR), [], 2);
k0 = klasa_di(Dbar, THR);
z = gam ./ max(sD, 1e-12);
p_k0 = Pk(sub2ind(size(Pk), (1:K)', k0));
viol = (z > 1) & (p_k0 < 1 - 1 ./ z.^2);
rez04.shkelje_kufiri_pct = round(100 * mean(viol), 2);
rez04.spearman_raw = round(spearman_r(gam, Pmax), 3);
rez04.spearman_standardizuar = round(spearman_r(z, Pmax), 3);
disp(rez04);

% grids for the figure script
Pmax_grid = nan(size(mask));
Kmod_grid = zeros(size(mask));
tmp = Pmax(ic); Pmax_grid(mask) = tmp;
tmp = Kmod(ic); Kmod_grid(mask) = tmp;
save(fullfile(RES, 'm04_fig.mat'), 'Pmax_grid', 'Kmod_grid', '-v7.3');
save(fullfile(RES, 'm04_rez.mat'), 'rez04');
save(fullfile(RES, 'm04_profile.mat'), 'famu', 'Pk', 'Pmax', 'Kmod', 'Dbar', 'sD', 'gam', 'z');
fprintf('m04 done.\n');
