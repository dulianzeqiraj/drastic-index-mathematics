% m12_diagnostics
% Convergence diagnostics for the hierarchical posterior: the potential scale
% reduction over the four whole chains, and the stricter split-chain form of the same
% statistic, together with the bulk effective sample size of every component.
%
% The split-chain form halves each chain and treats the halves as separate chains, so
% that a chain drifting within itself is caught. The effective sample size uses the
% initial positive sequence: the autocovariance is taken by FFT, the correlation is
% summed in adjacent pairs, and the sum stops at the first non-positive pair.
%
% Requires m10_chains.mat. Base MATLAB, no toolboxes.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

[~, RES] = paths_repo();
S = load(fullfile(RES, 'm10_chains.mat'));
A = S.A;                                   % chains x draws x parameters
[C, L, P] = size(A);
F = double(S.F); d = double(S.d);
fprintf('%d chains x %d draws x %d parameters\n', C, L, P);

Rp = psrf(A);
half = floor(L/2);
Rs = psrf(cat(1, A(:, 1:half, :), A(:, half+1:2*half, :)));

ess = zeros(P, 1);
for j = 1:P
    ess(j) = ess_bulk(A(:, :, j));
end
ess = min(ess, C*L);                       % an estimate above the draw count is noise

names = cell(P, 1); k = 0;
for f = 1:F
    for p = 1:d
        k = k + 1; names{k} = sprintf('u[%d,%d]', f, p);
    end
end
for f = 1:F, k = k + 1; names{k} = sprintf('b[%d]', f); end
for p = 1:d, k = k + 1; names{k} = sprintf('mu[%d]', p); end
for p = 1:d, k = k + 1; names{k} = sprintf('log tau[%d]', p); end
names{P} = 'log sigma';

iu = 1:(F*d);  ib = F*d + (1:F);
imu = F*d + F + (1:d);  itau = F*d + F + d + (1:d);
ial = 1:d;                                  % alluvial family weights

[~, jRs] = max(Rs);
[~, jess] = min(ess);
rez12 = struct();
rez12.chains = C; rez12.draws_per_chain = L; rez12.draws_total = C*L;
rez12.rhat_plain_max = round(max(Rp), 3);
rez12.rhat_split_max = round(max(Rs), 3);
rez12.rhat_split_worst = names{jRs};
rez12.ess_weights_min = round(min(ess(iu)));
rez12.ess_weights_max = round(max(ess(iu)));
rez12.ess_weights_median = round(median(ess(iu)));
rez12.ess_alluvial_min = round(min(ess(ial)));
rez12.ess_alluvial_max = round(max(ess(ial)));
rez12.ess_alluvial_median = round(median(ess(ial)));
rez12.ess_intercepts_min = round(min(ess(ib)));
rez12.ess_mu_min = round(min(ess(imu)));
rez12.ess_tau_min = round(min(ess(itau)));
rez12.ess_min = round(min(ess));
rez12.ess_min_at = names{jess};

fprintf('R-hat, four whole chains, max over %d components : %.3f\n', P, max(Rp));
fprintf('R-hat, split-chain, max                          : %.3f  (%s)\n', max(Rs), names{jRs});
fprintf('bulk ESS, 28 weight components                   : %.0f to %.0f of %d\n', ...
        min(ess(iu)), max(ess(iu)), C*L);
fprintf('bulk ESS, alluvial weights                       : %.0f to %.0f\n', ...
        min(ess(ial)), max(ess(ial)));
fprintf('bulk ESS, family intercepts, min                 : %.0f\n', min(ess(ib)));
fprintf('bulk ESS, population mean, min                   : %.0f\n', min(ess(imu)));
fprintf('bulk ESS, log between-family spread, min         : %.0f\n', min(ess(itau)));
fprintf('bulk ESS, smallest of all                        : %.0f  (%s)\n', min(ess), names{jess});

save(fullfile(RES, 'm12_rez.mat'), 'rez12', 'Rp', 'Rs', 'ess', 'names');
fid = fopen(fullfile(RES, 'diagnostics.json'), 'w');
fprintf(fid, '%s', jsonencode(rez12, 'PrettyPrint', true));
fclose(fid);
fprintf('m12 done.\n');

function R = psrf(A)
% Potential scale reduction, chains x draws x parameters.
L = size(A, 2);
W = squeeze(mean(var(A, 0, 2), 1))';
B = L * squeeze(var(mean(A, 2), 0, 1))';
R = sqrt(((L-1)/L * W + B/L) ./ max(W, 1e-12));
end

function n = ess_bulk(ch)
% Bulk effective sample size from the initial positive sequence, chains x draws.
[C, L] = size(ch);
W = mean(var(ch, 0, 2));
if W <= 0, n = C*L; return; end
Bd = var(mean(ch, 2), 0, 1);
varplus = (L-1)/L * W + Bd;
n2 = 2^nextpow2(2*L);
acov = zeros(1, L);
for c = 1:C
    x = ch(c, :) - mean(ch(c, :));
    f = fft(x, n2);
    a = real(ifft(f .* conj(f)));
    acov = acov + a(1:L) / L;
end
acov = acov / C;
rho = 1 - (W - acov) / varplus;
rho(1) = 1;
t = 2; tot = 0;
while t + 1 <= L
    p = rho(t) + rho(t+1);
    if p < 0, break; end
    tot = tot + p;
    t = t + 2;
end
n = C * L / max(-1 + 2*tot, 1e-9);
end
