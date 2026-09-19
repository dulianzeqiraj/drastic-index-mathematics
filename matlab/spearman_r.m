
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.
function r = spearman_r(a, b)
% Spearman rank correlation with average ranks for ties (base MATLAB only).
ra = tied_rank(a(:));
rb = tied_rank(b(:));
c = corrcoef(ra, rb);
r = c(1, 2);
end

function r = tied_rank(x)
[~, ord] = sort(x);
r = zeros(size(x));
r(ord) = 1:numel(x);
% average ranks over ties
[xs, ords] = sort(x);
i = 1;
while i <= numel(x)
    j = i;
    while j < numel(x) && xs(j + 1) == xs(i)
        j = j + 1;
    end
    if j > i
        r(ords(i:j)) = mean(r(ords(i:j)));
    end
    i = j + 1;
end
end
