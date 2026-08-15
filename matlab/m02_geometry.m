% m02_geometry
% Layer II and III computations on the attainable profile set:
% affine rank of the national profile set, family-level covariance ranks,
% the A -> (R, C) coupling, the threshold hyperplane count, the Zaslavsky
% bound, and the consensus-weight margins.
% Requires: profilet.mat (from m01), kalibrimi_62_pika.json.

[DATA, RES] = paths_repo();
W = [5 4 3 2 1 5 3];
THR = [55 90 125 160];
load(fullfile(RES, 'profilet.mat'), 'Runiq', 'counts');
K = size(Runiq, 1);

% national affine rank: singular values of the centered unique-profile matrix
Rc = Runiq - mean(Runiq, 1);
sv = svd(Rc);
fprintf('singular values: %s\n', mat2str(round(sv', 3)));

% A -> C and A -> R coupling on the grid (area-weighted, unique profiles x counts)
iA = 3; iR = 2; iC = 7;
Avals = unique(Runiq(:, iA));
maxCperA = 0; maxRperA = 0; areaModal = 0;
for a = Avals'
    sel = Runiq(:, iA) == a;
    cvals = unique(Runiq(sel, iC));
    rvals = unique(Runiq(sel, iR));
    maxCperA = max(maxCperA, numel(cvals));
    maxRperA = max(maxRperA, numel(rvals));
    % modal C for this A, by area
    wsum = zeros(numel(cvals), 1);
    for j = 1:numel(cvals)
        wsum(j) = sum(counts(sel & Runiq(:, iC) == cvals(j)));
    end
    areaModal = areaModal + max(wsum);
end
pctModal = 100 * areaModal / sum(counts);

% calibration-footprint covariance spectra (62 points; alluvial subset)
raw = fileread(fullfile(DATA, 'kalibrimi_62_pika.json'));
pts = jsondecode(raw);
if ~iscell(pts), pts = num2cell(pts); end
n = numel(pts);
X = zeros(n, 7);
fam = strings(n, 1);
PAR = 'DRASTIC';
for i = 1:n
    for p = 1:7
        X(i, p) = pts{i}.rates.(PAR(p));
    end
    fam(i) = string(pts{i}.familja);
end
% population covariance (normalization by n), the convention of the archived run
ev_full = sort(eig(cov(X, 1)), 'descend');
Xal = X(fam == "aluvional", :);
ev_al = sort(eig(cov(Xal, 1)), 'descend');
[V, D] = eig(cov(Xal, 1));
[~, ord] = sort(diag(D));
kern1 = V(:, ord(1));   % the two near-null directions
kern2 = V(:, ord(2));

% hyperplane count: pairs (profile, threshold) whose hyperplane crosses the simplex
rmin = min(Runiq, [], 2);
rmax = max(Runiq, [], 2);
cross = 0;
for k = 1:4
    cross = cross + nnz(23 * rmin < THR(k) & THR(k) < 23 * rmax);
end
% Zaslavsky chamber bound in dimension 6: sum_{i=0}^{6} C(m, i), via log-safe products
m = cross;
tot = 0;
for i = 0:6
    tot = tot + prod((m - i + 1):m) / factorial(i);
end
zas_log10 = log10(tot);

% consensus margins over attainable profiles, area-weighted
DIu = Runiq * W';
marg = min(abs(DIu - THR), [], 2);
onthr = marg == 0;
% area-weighted median and mean via expansion by counts (weighted percentile)
[msort, mo] = sort(marg);
csort = cumsum(counts(mo));
medw = msort(find(csort >= 0.5 * sum(counts), 1));
meanw = sum(marg .* counts) / sum(counts);
minpos = min(marg(marg > 0));

rez02 = struct();
rez02.profile_unike = K;
rez02.sv_kombetar = round(sv', 3);
rez02.rang_kombetar = nnz(sv > 1e-6);
rez02.ev_footprint_62 = round(ev_full', 4);
rez02.ev_aluvional = round(ev_al', 6);
rez02.rang_aluvional = nnz(ev_al > 1e-6);
rez02.kernel1 = round(kern1', 2);
rez02.kernel2 = round(kern2', 2);
rez02.max_C_per_A = maxCperA;
rez02.max_R_per_A = maxRperA;
rez02.pct_modal_AC = round(pctModal, 1);
rez02.hiperplane = cross;
rez02.zaslavsky_log10 = round(zas_log10, 2);
rez02.profile_mbi_prag = nnz(onthr);
rez02.km2_mbi_prag = sum(counts(onthr)) * 0.01;
rez02.marzh_min_pozitiv = minpos;
rez02.marzh_median_pond = medw;
rez02.marzh_mes_pond = round(meanw, 2);
disp(rez02);
save(fullfile(RES, 'm02_rez.mat'), 'rez02');
fprintf('m02 done.\n');
