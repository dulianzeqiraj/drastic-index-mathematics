
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.
function v = pctl(x, p)
% Percentile with linear interpolation (same convention as numpy.percentile).
% x: vector; p: scalar or vector of percentages in [0, 100].
x = sort(x(:));
n = numel(x);
v = zeros(size(p));
for i = 1:numel(p)
    idx = (n - 1) * p(i) / 100;
    lo = floor(idx);
    fr = idx - lo;
    if lo + 2 <= n
        v(i) = x(lo + 1) * (1 - fr) + x(lo + 2) * fr;
    else
        v(i) = x(n);
    end
end
end
