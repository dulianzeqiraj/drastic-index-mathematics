function lp = logpost_hier(th, Xc, y, se2, fam, F, d, WD, ybar)
% Log-posterior of the hierarchical DRASTIC weight model (eqs. 13-15 of the
% manuscript): Gaussian observation law with station-specific variance,
% truncated-normal family weights pooled toward a truncated-normal hypermean
% centered at the Delphi vector, half-normal scales.
u = reshape(th(1:F*d), d, F)';                 % F x d, row-major layout
b = th(F*d+1 : F*d+F);
mu = th(F*d+F+1 : F*d+F+d);
tau = exp(th(F*d+F+d+1 : F*d+F+2*d));
sigma = exp(th(end));
if any(u(:) < 0) || any(mu < 0)
    lp = -inf;
    return
end
pred = b(fam) + sum(Xc .* u(fam, :), 2);
v = sigma^2 + se2;
lp = -0.5 * sum((y - pred).^2 ./ v + log(v));
lp = lp - 0.5 * sum(sum((u - mu').^2 ./ (tau'.^2))) - F * sum(log(tau));
lp = lp - 0.5 * sum((mu - WD).^2 / 2.5^2);
lp = lp - 0.5 * sum(tau.^2 / 1.5^2) + sum(log(tau));   % HalfNormal(1.5) + Jacobian
lp = lp - 0.5 * sum((b - ybar).^2 / 10^2);
lp = lp - 0.5 * sigma^2 / 10^2 + log(sigma);           % HalfNormal(10) + Jacobian
end
