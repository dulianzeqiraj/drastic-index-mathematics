
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.
function out = run_chain_hier(iters, burn, seed, Xc, y, se2, fam, F, d, WD, ybar, sigma0)
% One component-wise Metropolis chain with step adaptation during burn-in,
% thinned by 10 after burn-in. Mirrors the archived Python sampler.
rng(seed, 'twister');
DIM = F*d + F + d + d + 1;
u0 = (repmat(WD', F, 1) .* (0.5 + rand(F, d)));
th = [reshape(u0', [], 1); ybar + randn(F, 1); WD .* (0.7 + 0.6*rand(d, 1)); ...
      zeros(d, 1); log(sigma0)];
lp = logpost_hier(th, Xc, y, se2, fam, F, d, WD, ybar);
step = 0.15 * ones(DIM, 1);
acc = zeros(DIM, 1);
nkeep = numel(burn:10:iters-1);
out = zeros(nkeep, DIM);
cnt = 0;
for it = 0:iters-1
    for j = 1:DIM
        prop = th;
        prop(j) = prop(j) + randn * step(j);
        lpp = logpost_hier(prop, Xc, y, se2, fam, F, d, WD, ybar);
        if log(rand) < lpp - lp
            th = prop;
            lp = lpp;
            acc(j) = acc(j) + 1;
        end
    end
    if it < burn && mod(it, 200) == 199
        rate = acc / 200;
        step = step .* ((rate > 0.5) * 1.4 + (rate < 0.2) * 0.7 + ...
                        (rate >= 0.2 & rate <= 0.5) * 1.0);
        acc(:) = 0;
    end
    if it >= burn && mod(it, 10) == 0
        cnt = cnt + 1;
        out(cnt, :) = th';
    end
end
out = out(1:cnt, :);
end
