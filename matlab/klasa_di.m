function k = klasa_di(x, c)
% DRASTIC class from index value(s): class k iff c(k-1) <= x < c(k).
% Matches the convention of the recovered national map (thresholds inclusive below).
if nargin < 2
    c = [55 90 125 160];
end
k = 1 + (x >= c(1)) + (x >= c(2)) + (x >= c(3)) + (x >= c(4));
end
