% m11_cv_auc
% Discrimination of the deployed index against measured nitrate, scored twice: once
% fitted on all 62 points, and once under 8-fold cross-validation, refitting the
% hierarchy on each training fold and scoring the held-out points with the sum-23
% posterior median weights of that fold alone. An area computed on the points the
% posterior was fitted to flatters it, which is why both are kept. The 1987 index
% needs no refitting and is scored on the same points, which is the comparison that
% matters.
%
% Ranks are averaged over ties throughout, because the rating alphabets are finite
% and the index takes repeated values.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

[DATA, RES] = paths_repo();
WD = [5 4 3 2 1 5 3]';
FAMS = {'aluvional','karbonatik','magmatik','flish_argjile'};
PAR = 'DRASTIC'; F = 4; d = 7;

pts = jsondecode(fileread(fullfile(DATA,'kalibrimi_62_pika.json')));
if ~iscell(pts), pts = num2cell(pts); end
n = numel(pts);
X = zeros(n,d); y = zeros(n,1); se = zeros(n,1); fam = zeros(n,1);
for i = 1:n
    for p = 1:d, X(i,p) = pts{i}.rates.(PAR(p)); end
    y(i) = pts{i}.no3;
    if isfield(pts{i},'se_no3') && ~isempty(pts{i}.se_no3), se(i) = pts{i}.se_no3; end
    fam(i) = find(strcmp(FAMS, pts{i}.familja));
end
rbar = mean(X,1); se2 = se.^2;
fprintf('nitrate at the %d points: %.2f to %.2f, median %.2f, mean %.2f\n', ...
        n, min(y), max(y), median(y), mean(y));
fprintf('above 10 mg/L: %d; above 50 mg/L: %d\n', nnz(y > 10), nnz(y > 50));

% ---------------------------------------------------------------- fitted on all points
S = load(fullfile(RES,'m10_chains.mat'), 'A');
D2 = reshape(permute(S.A, [2 1 3]), [], size(S.A,3));
U = zeros(size(D2,1), F, d);
for f = 1:F, U(:,f,:) = D2(:, (f-1)*d + (1:d)); end
Un = zeros(size(U));
for f = 1:F
    Uf = squeeze(U(:,f,:)); s = sum(Uf,2); ok = s > 1e-9;
    Un(ok,f,:) = 23 * Uf(ok,:) ./ s(ok);
end
wfit = squeeze(median(Un,1));
idx_fit = zeros(n,1);
for i = 1:n, idx_fit(i) = X(i,:) * wfit(fam(i),:)'; end
idx_del = X * WD;

% ---------------------------------------------------------------- cross-validated
rng(11,'twister');
K = 8;
ord = randperm(n);
foldid = zeros(n,1);
for k = 1:K, foldid(ord(k:K:end)) = k; end

idx_cv = nan(n,1);
tcv = tic;
for k = 1:K
    tr = foldid ~= k; te = ~tr;
    ch = run_chain_hier(12000, 5000, 900+k, X(tr,:) - rbar, y(tr), se2(tr), fam(tr), ...
                        F, d, WD, mean(y(tr)), 5.0);
    Uk = zeros(size(ch,1), F, d);
    for f = 1:F, Uk(:,f,:) = ch(:, (f-1)*d + (1:d)); end
    Unk = zeros(size(Uk));
    for f = 1:F
        Uf = squeeze(Uk(:,f,:)); s = sum(Uf,2); ok = s > 1e-9;
        Unk(ok,f,:) = 23 * Uf(ok,:) ./ s(ok);
    end
    wk = squeeze(median(Unk,1));
    ii = find(te);
    for j = 1:numel(ii), idx_cv(ii(j)) = X(ii(j),:) * wk(fam(ii(j)),:)'; end
    fprintf('fold %d/%d: %d held out  [%.0f s]\n', k, K, nnz(te), toc(tcv));
end

% ---------------------------------------------------------------- scores
rez11 = struct();
rez11.k_folds = K;
rez11.n = n;
rez11.nitrate = struct('min', round(min(y),2), 'max', round(max(y),2), ...
                       'median', round(median(y),2), 'above10', nnz(y > 10));
rez11.spearman_fitted = round(spearman_r(idx_fit, y), 3);
rez11.spearman_cv = round(spearman_r(idx_cv, y), 3);
rez11.spearman_delphi = round(spearman_r(idx_del, y), 3);

thr = [10, prctile_local(y,75)];
nm = {'thr_10mgL','thr_upper_quartile'};
for t = 1:numel(thr)
    pos = y > thr(t);
    rez11.(nm{t}) = struct('threshold', round(thr(t),2), 'n_positive', nnz(pos), ...
                           'auc_fitted', round(auc_tied(idx_fit,pos),3), ...
                           'auc_cv',     round(auc_tied(idx_cv,pos),3), ...
                           'auc_delphi', round(auc_tied(idx_del,pos),3));
    fprintf('AUC at %.2f mg/L (%d positive): fitted %.3f, cross-validated %.3f, Delphi %.3f\n', ...
            thr(t), nnz(pos), rez11.(nm{t}).auc_fitted, rez11.(nm{t}).auc_cv, ...
            rez11.(nm{t}).auc_delphi);
end
fprintf('Spearman: fitted %.3f, cross-validated %.3f, Delphi %.3f\n', ...
        rez11.spearman_fitted, rez11.spearman_cv, rez11.spearman_delphi);

save(fullfile(RES,'m11_rez.mat'),'rez11','idx_fit','idx_cv','idx_del','y','fam');
fid = fopen(fullfile(RES,'cv_auc.json'),'w');
fprintf(fid,'%s', jsonencode(rez11,'PrettyPrint',true)); fclose(fid);
fprintf('m11 done in %.0f s.\n', toc(tcv));

function a = auc_tied(score, pos)
% Area under the ROC curve, ranks averaged over ties.
pos = logical(pos(:)); score = score(:);
if ~any(pos) || all(pos), a = NaN; return; end
r = tied_rank_local(score);
n1 = sum(pos); n0 = sum(~pos);
a = (sum(r(pos)) - n1*(n1+1)/2) / (n1*n0);
end

function r = tied_rank_local(x)
[xs, ord] = sort(x);
r = zeros(size(x));
r(ord) = 1:numel(x);
i = 1;
while i <= numel(x)
    j = i;
    while j < numel(x) && xs(j+1) == xs(i), j = j + 1; end
    if j > i, r(ord(i:j)) = mean(r(ord(i:j))); end
    i = j + 1;
end
end

function q = prctile_local(x, p)
x = sort(x(:)); n = numel(x);
pos = p/100 * n + 0.5;
lo = max(floor(pos),1); hi = min(ceil(pos),n);
q = x(lo) + (pos-lo)*(x(hi)-x(lo));
end
