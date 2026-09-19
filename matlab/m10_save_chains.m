% m10_save_chains
% Runs the four chains of m03 with the same seeds and keeps them apart instead of
% pooling them, so that split-chain diagnostics and an effective sample size can be
% computed per component. Also saves the calibration design, so that the deployed
% index at the 62 points can be scored against the observations.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

[DATA, RES] = paths_repo();
WD = [5 4 3 2 1 5 3]';
FAMS = {'aluvional', 'karbonatik', 'magmatik', 'flish_argjile'};
PAR = 'DRASTIC'; F = 4; d = 7;

pts = jsondecode(fileread(fullfile(DATA, 'kalibrimi_62_pika.json')));
if ~iscell(pts), pts = num2cell(pts); end
n = numel(pts);
X = zeros(n, d); y = zeros(n, 1); se = zeros(n, 1); fam = zeros(n, 1);
for i = 1:n
    for p = 1:d, X(i, p) = pts{i}.rates.(PAR(p)); end
    y(i) = pts{i}.no3;
    if isfield(pts{i}, 'se_no3') && ~isempty(pts{i}.se_no3), se(i) = pts{i}.se_no3; end
    fam(i) = find(strcmp(FAMS, pts{i}.familja));
end
rbar = mean(X, 1); Xc = X - rbar; ybar = mean(y); se2 = se.^2;

ITERS = 24000; BURN = 8000;
C = cell(1, 4);
for c = 1:4
    t = tic;
    C{c} = run_chain_hier(ITERS, BURN, 100 + c, Xc, y, se2, fam, F, d, WD, ybar, 5.0);
    fprintf('chain %d: %d draws, %.0f s\n', c, size(C{c}, 1), toc(t));
end
L = min(cellfun(@(x) size(x, 1), C));
A = zeros(4, L, size(C{1}, 2));
for c = 1:4, A(c, :, :) = C{c}(1:L, :); end
save(fullfile(RES, 'm10_chains.mat'), 'A', 'X', 'y', 'se', 'fam', 'rbar', 'F', 'd', '-v7');
fprintf('m10 saved: %d chains x %d draws x %d parameters\n', size(A, 1), size(A, 2), size(A, 3));
